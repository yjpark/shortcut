import logging
import sys
import threading
import tornado.escape
import uuid
from websocket import client75

from shortcut.channel import const as C
from shortcut import config as CONFIG

def is_compatable(m):
    # whitelist checked first
    platform_whitelist = getattr(m, 'platform_whitelist', None)
    if platform_whitelist is not None:
        logging.info('platform_whitelist = %s' % platform_whitelist)
        if sys.platform in platform_whitelist:
            return True
        else:
            return False
    # then checking blacklist
    platform_blacklist = getattr(m, 'platform_blacklist', None)
    if platform_blacklist is not None:
        logging.info('platform_blacklist = %s' % platform_blacklist)
        if sys.platform in platform_blacklist:
            return False
        else:
            return True

    return True

def threaded(callback=lambda *args, **kwargs: None, daemonic=False):
    """Decorate a function to run in its own thread and report the result
    by calling callback with it."""
    def innerDecorator(func):
        def inner(*args, **kwargs):
            target = lambda: callback(func(*args, **kwargs))
            t = threading.Thread(target=target)
            t.setDaemon(daemonic)
            t.start()
        return inner
    return innerDecorator

class ShortcutChannelError(Exception):
    pass


class AbstractChannel(object):
    protocol = None

    def __init__(self, url, auth_code):
        self.auth_code = auth_code
        if url.startswith('wss75'):
            socket_class = client75.WebSocket
            url = url.replace('wss75://', 'wss://')
        else:
            raise ShortcutChannelError('Only wss75 protocol supported now')

        logging.info('Creating channel: url = %s, class = %s'
                     % (url, self.__class__))
        self.socket = socket_class(url,
            onopen=self.on_open,
            onclose=self.on_close,
            onerror=self.on_error,
            onmessage=self.on_message,
        )
        self.channel = self.protocol[C.TYPE] +'/' + str(uuid.uuid1())

    def on_open(self):
        logging.info('on_open %s' % self.channel)
        self.authenticated = False
        self.socket.send(self.auth_code)

    def on_authenticate(self, msg):
        logging.info('on_authenticate %s, %s' % (self.channel, msg))
        if msg == 'ACK':
            self.authenticated = True
            self.send_protocol()

    def send_protocol(self):
        msg = {
            C.OP: C.PROTOCOL,
            C.CHANNEL: self.channel,
            C.DATA: self.protocol,
        }
        self.send_message(msg)

    def on_close(self):
        logging.info('on_close %s' % self.channel)

    def on_error(self, e):
        logging.info('on_error %s: %s' % (self.channel, e), exc_info=True)

    def on_message(self, msg):
        if not self.authenticated:
            return self.on_authenticate(msg)

        logging.debug('on_message %s: %s' % (self.channel, msg))
        try:
            msg = tornado.escape.json_decode(msg)
            op = msg[C.OP]
            if op == C.CONTROL:
                self.on_control(msg)
            elif op == C.PROTOCOL:
                self.on_protocol(msg)
            else:
                raise ShortcutChannelError('Only control/protocol allowed '
                            'from client: op = %s' % op)
        except Exception, e:
            logging.info('on_message error %s: %s' % (self.channel, e),
                        exc_info=True)
            result = {
                C.OP: C.NOTIFY,
                C.CHANNEL: self.channel,
                C.DATA: {
                    C.TYPE: C.ERROR,
                    C.ORIGINAL_MSG: msg,
                    C.ERROR: repr(e),
                },
            }
            self.send_message(result)

    def on_control(self, msg):
        data = msg[C.DATA]
        cmd = data[C.CMD]
        cmd_protocol = self.protocol[C.CMDS][cmd]
        args = {C.MSG: msg}
        for key in cmd_protocol:
            parameter_protocol = cmd_protocol[key]
            value = data.get(key)
            self.validate_parameter(parameter_protocol, value)
            if value is not None:
                args[key] = value
        handler = self.__getattribute__('on_%s' % cmd)
        result = handler(**args)
        if result is None:
            return
            result = {}
        result[C.ORIGINAL_MSG] = msg
        result = {
            C.OP: C.NOTIFY,
            C.CHANNEL: self.channel,
            C.DATA: result,
        }
        self.send_message(result)

    def on_protocol(self, msg):
        pass

    def send_message(self, msg, from_thread=False):
        logging.debug('send_message %s: %s' % (self.channel, msg))
        self.socket.send(tornado.escape.json_encode(msg))
        if from_thread:
            self.socket.flush()

    def send_notify(self, data, original_msg=None, from_thread=False):
        msg = {
            C.OP: C.NOTIFY,
            C.CHANNEL: self.channel,
            C.DATA: data,
        }
        if original_msg:
            msg[C.ORIGINAL_MSG] = original_msg
        self.send_message(msg, from_thread=from_thread)

    def validate_parameter(self, parameter_protocol, value):
        #TODO
        pass

class ShortcutChannelsModel(object):
    def __init__(self):
        self.channels = []

    def create_channel(self, url, auth_code, _class):
        channel = _class(url, auth_code)
        self.channels.append(channel)
        return channel

    def remove_channel(self, channel):
        self.channels.remove(channel)


# Singleton
model = ShortcutChannelsModel()

