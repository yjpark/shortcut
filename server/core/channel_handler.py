import logging
import tornado
import tornado.escape

from core import login_handler
from core import shortcut_server_model as M
from shortcut.channel import const as C

class ChannelHandler(login_handler.BaseHandler):
    """
    This handler is to proxy the static files of channels to their clients 
    """
    @tornado.web.authenticated
    def get(self, channel_type, channel_id, path):
        # TODO
        self.write('<html><body>TEST<br/>%s/%s<br/>%s'
                   '</body></html>' % (channel_type, channel_id, path))

    def get_post_msg(self, channel, path):
        data = {}
        try:
            if self.request.body:
                data = tornado.escape.json_decode(self.request.body)
        except Exception, e:
            logging.error('Error Decoding Post Data: [%s] %s: %s'
                       % (channel.identifier, path, self.request.body))
        data[C.CMD] = path
        msg = {
            C.OP: C.CONTROL,
            C.CHANNEL: channel.identifier,
            C.DATA: data,
        }
        return msg

    def post_to_channel(self, channel, msg):
        if channel.allow_http_control():
            channel.on_control(msg)
        else:
            raise M.ShortcutServerError(
                'This channel does not allow control over HTTP: %s'
                % channel.identifier)

    def post(self, *args, **kw_args):
        try:
            self._post(*args, **kw_args)
        except Exception, e:
            logging.error('POST Error: %s' % e, exc_info=True)
            self.write('Error: %s' % e)

    def _post(self, channel_type, channel_id, path):
        logging.info('POST to Channel [%s/%s]: %s: %s'
                % (channel_type, channel_id, path, self.request.body))
        channel = M.model.channels.get('%s/%s' % (channel_type, channel_id))
        if channel is not None:
            msg = self.get_post_msg(channel, path)
            self.post_to_channel(channel, msg)
            self.write(tornado.escape.json_encode(msg))
        else:
            raise M.ShortcutServerError(
                'Can not do POST to non-exist channel: [%s/%s] %s'
                % (channel_type, channel_id, path))


class ServiceHandler(ChannelHandler):
    """
    This handler is to proxy the static files of channels to their clients 
    """
    @tornado.web.authenticated
    def get(self, channel_type, path):
        # TODO
        self.write('<html><body>TEST<br/>%s<br/>%s'
                   '</body></html>' % (channel_type, path))

    def _post(self, channel_type, path):
        logging.info('POST to Service [%s]: %s: %s'
                % (channel_type, path, self.request.body))
        channel = M.model.get_channel_by_type(channel_type)
        if channel is not None:
            msg = self.get_post_msg(channel, path)
            self.post_to_channel(channel, msg)
            self.write(tornado.escape.json_encode(msg))
        else:
            raise M.ShortcutServerError(
                'Can not do POST to non-exist service: [%s] %s'
                % (channel_type, path))

