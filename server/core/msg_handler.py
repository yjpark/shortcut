import logging
import tornado
import tornado.escape
import uuid

from websocket import server75
from websocket import server76
from shortcut.channel import const as C

from core import login_handler
from core.shortcut_server_model import model as M
from core.shortcut_server_model import ShortcutServerError

class MsgMixin():
    def _init_mixin(self):
        self.owning_channels = {}
        self.listening_channels = {}
        self.identifier = str(uuid.uuid1())
        self.opened = False
        self.authenticated = False

    def __str__(self):
        return '%s/%s' % (self.request.remote_ip, self.identifier)

    def open(self):
        logging.info('msg connection open %s' % self)
        M.add_connection(self)
        self.opened = True
        self.authenticated = False
        self.receive_message(self.on_authenticate)

    def send_message(self, msg):
        logging.debug('send_message: %s: %s' % (self, msg))
        #assert self.authenticated
        try:
            self.write_message(msg)
        except Exception, e:
            logging.error('send_message failed %s, %s, %s' %
                         (self, msg, e), exc_info=True)

    def on_connection_close(self):
        logging.info('msg connection close %s' % self)
        if self.opened:
            M.remove_connection(self)
        for channel in self.listening_channels.values():
            channel.remove_listener(self)
        self.listening_channels = {}

        for channel in self.owning_channels.values():
            M.close_channel(channel, self)
        self.owning_channels = {}

    def on_authenticate(self, auth_code):
        logging.debug('on_authenticate: %s' % auth_code)
        assert not self.authenticated
        if auth_code == M.auth_code:
            self.authenticated = True
            self.send_message('ACK')
            M.broadcast_channels(self)
            self.receive_message(self.on_message)
        else:
            self.send_message('NAK')
            self.receive_message(self.on_authenticate)

    def on_message(self, msg):
        logging.debug('on_message: %s: %s' % (self, msg))
        assert self.authenticated
        identifier = '-'
        try:
            msg = tornado.escape.json_decode(msg)
            op = msg[C.OP]
            identifier = msg[C.CHANNEL]

            if op == C.NOTIFY:
                self.on_notify(identifier, msg)
            elif op == C.CONTROL:
                self.on_control(identifier, msg)
            elif op == C.LISTEN:
                self.on_listen(identifier, msg)
            elif op == C.PROTOCOL:
                self.on_protocol(identifier, msg)
        except Exception, e:
            logging.error('on_message error: %s/%s: %s' %
                         (self, identifier, e), exc_info=True)
        self.receive_message(self.on_message)

    def on_protocol(self, identifier, msg):
        channel = self.owning_channels.get(identifier, None)
        if not channel:
            channel = M.open_channel(identifier, self)
        channel.protocol = msg
        self.owning_channels[identifier] = channel
        logging.info('on_protocol %s/%s: %s' % (self, identifier, msg))
        M.broadcast_channel(self, channel)

    def on_listen(self, identifier, msg):
        if identifier not in self.listening_channels:
            channel = M.listen_channel(identifier, self)
            self.listening_channels[identifier] = channel
            logging.info('on_listen %s/%s: %s' % (self, identifier, msg))
        else:
            logging.warning('on_listen already listening: %s/%s: %s' %
                           (self, identifier, msg))

    def on_unlisten(self, identifier):
        self.listening_channels.pop(identifier)
        logging.info('on_unlisten %s/%s' % (self, identifier))

    def on_control(self, identifier, msg):
        if identifier in self.listening_channels:
            channel = self.listening_channels[identifier]
            channel.on_control(msg)
            logging.info('on_control %s/%s: %s' % (self, identifier, msg))
        else:
            logging.warning('on_control on not-listening channel: %s/%s: %s' %
                           (self, identifier, msg))

    def on_notify(self, identifier, msg):
        if identifier in self.owning_channels:
            channel = self.owning_channels[identifier]
            channel.on_notify(msg)
            logging.info('on_notify %s/%s: %s' % (self, identifier, str(msg)[:128]))
        else:
            logging.warning('on_notify on not-owning channel: %s/%s: %s' %
                           (self, identifier, msg))


class MsgHandler75(server75.WebSocketHandler, MsgMixin):
    def __init__(self, *args, **kwargs):
        kwargs['secure'] = True
        server75.WebSocketHandler.__init__(self, *args, **kwargs)
        self._init_mixin()

    def __str__(self):
        return MsgMixin.__str__(self)

    def on_connection_close(self):
        return MsgMixin.on_connection_close(self)


class MsgHandler76(server76.WebSocketHandler, MsgMixin):
    def __init__(self, *args, **kwargs):
        kwargs['secure'] = True
        server76.WebSocketHandler.__init__(self, *args, **kwargs)
        self._init_mixin()

    def __str__(self):
        return MsgMixin.__str__(self)

    def on_connection_close(self):
        return MsgMixin.on_connection_close(self)


