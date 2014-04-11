import logging

from shortcut.channel import const as C
from shortcut import config as CONFIG

class ShortcutServerError(Exception):
    pass

class Channel(object):
    def __init__(self, identifier, owner):
        self.identifier = identifier
        self.owner = owner
        self.listeners = []
        self.protocol = None
        logging.info('channel created %s/%s' % (owner, identifier))

    def add_listener(self, socket):
        if socket not in self.listeners:
            self.listeners.append(socket)
            msg = {
                C.OP: C.NOTIFY,
                C.CHANNEL: self.identifier,
                C.DATA: {
                    C.TYPE: C.LISTENING,
                },
            }
            socket.send_message(msg)
            logging.info('add_listener %s: %s' % (self.identifier, socket))

    def remove_listener(self, socket):
        if socket in self.listeners:
            socket.on_unlisten(self.identifier)
            self.listeners.remove(socket)
            logging.info('remove_listener %s: %s' % (self.identifier, socket))

    def on_control(self, msg):
        if self.owner:
            self.owner.send_message(msg)
        else:
            self.close()

    def on_notify(self, msg):
        for socket in self.listeners:
            socket.send_message(msg)

    def close(self):
        msg = {
            C.OP: C.NOTIFY,
            C.CHANNEL: self.identifier,
            C.DATA: {
                C.TYPE: C.CLOSED,
            },
        }
        self.on_notify(msg)
        for socket in self.listeners:
            self.remove_listener(socket)

    def allow_http_control(self):
        if self.protocol and \
           self.protocol[C.DATA] and \
           self.protocol[C.DATA].get(C.ALLOW_HTTP_CONTROL, False):
            return True
        return False

class ShortcutServerModel(object):
    def __init__(self, auth_code):
        self.auth_code = auth_code
        self.channels = {}
        self.connections = []

    def add_connection(self, socket):
        self.connections.append(socket)

    def remove_connection(self, socket):
        self.connections.remove(socket)

    def open_channel(self, identifier, socket):
        if identifier in self.channels:
            raise ShortcutServerError('Channel alraedy exist')
        channel = Channel(identifier, socket)
        self.channels[identifier] = channel
        return channel

    def close_channel(self, channel, socket):
        if channel.owner != socket:
            raise ShortcutServerError('Only owner can close channel')
        channel.close()
        self.channels.pop(channel.identifier)

    def broadcast_channel(self, socket, channel):
        for conn in self.connections:
            if conn != socket:
                conn.send_message(channel.protocol)

    def broadcast_channels(self, socket):
        for ch in self.channels.values():
            socket.send_message(ch.protocol)

    def listen_channel(self, identifier, socket):
        channel = self.channels.get(identifier)
        if channel is None:
            raise ShortcutServerError('Channel not exist')
        channel.add_listener(socket)
        return channel

    def get_channel_by_type(self, channel_type):
        assert '/' not in channel_type
        key = channel_type + '/'
        for channel in self.channels.values():
            if channel.identifier.startswith(key):
                return channel
        return None

# Singleton
model = ShortcutServerModel(CONFIG.get_config(CONFIG.SERVER_SECTION, 'auth_code'))


