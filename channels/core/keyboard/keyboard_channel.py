import logging
from autopy import key as K

from shortcut.channel import const as C
from core import shortcut_channels_model as M

SPECIAL_KEYS = {
    'f1': K.K_F1,
    'f2': K.K_F2,
    'f3': K.K_F3,
    'f4': K.K_F4,
    'f5': K.K_F5,
    'f6': K.K_F6,
    'f7': K.K_F7,
    'f8': K.K_F8,
    'f9': K.K_F9,
    'f10': K.K_F10,
    'f11': K.K_F11,
    'f12': K.K_F12,
    'left': K.K_LEFT,
    'right': K.K_RIGHT,
    'up': K.K_UP,
    'down': K.K_DOWN,
    'pageup': K.K_PAGEUP,
    'pagedown': K.K_PAGEDOWN,
    'home': K.K_HOME,
    'end': K.K_END,
    'delete': K.K_DELETE,
    'return': K.K_RETURN,
    'escape': K.K_ESCAPE,
    'backspace': K.K_BACKSPACE,
    'capslock': K.K_CAPSLOCK,
    'control': K.K_CONTROL,
    'shift': K.K_SHIFT,
    'meta': K.K_META,
    'alt': K.K_ALT,
}

MODIFIERS = {
    'C': K.MOD_CONTROL,
    'S': K.MOD_SHIFT,
    'M': K.MOD_META,
    'A': K.MOD_ALT,
}

# Not defined yet
KEY_TYPE = C.STRING
MODIFIERS_TYPE = C.STRING

CMDS = {
    'type': {
        'string': C.STRING,
        'wpm': C.INTEGER,
    },
    'tap': {
        'key': KEY_TYPE,
        'modifiers': MODIFIERS_TYPE,
    },
    'press': {
        'key': KEY_TYPE,
        'modifiers': MODIFIERS_TYPE,
    },
    'release': {
        'key': KEY_TYPE,
        'modifiers': MODIFIERS_TYPE,
    },
}

TYPES = {
}

PROPERTIES = {
}

TITLE = 'Keyboard Controller'
DESCRIPTION = \
'You can simulate keyboard events.'

PROTOCOL = {
    C.TYPE: 'keyboard',
    C.TITLE: TITLE,
    C.DESCRIPTION: DESCRIPTION,
    C.CMDS: CMDS,
    #C.TYPES: TYPES,
    #C.PROPERTIES: PROPERTIES,
}

class KeyboardChannel(M.AbstractChannel):
    protocol = PROTOCOL

    def on_type(self, string, wpm=0, msg=None):
        K.type_string(string, wpm)

    def _get_key(self, key):
        result = SPECIAL_KEYS.get(key, None)
        if result is None:
            result = chr(ord(key[0]))
        logging.debug('Key = %s (%s)' % (result, key))
        return result

    def _get_modifiers(self, modifiers):
        result = K.MOD_NONE
        if not modifiers:
            return result

        for key, value in MODIFIERS.items():
            if key in modifiers:
                result = result | value
        logging.debug('Modifiers = %s (%s)' % (result, modifiers))
        return result

    def on_tap(self, key, modifiers=None, msg=None):
        key = self._get_key(key)
        modifiers = self._get_modifiers(modifiers)
        K.tap(key, modifiers)

    def on_press(self, key, modifiers=None, msg=None):
        key = self._get_key(key)
        modifiers = self._get_modifiers(modifiers)
        K.toggle(key, True, modifiers)

    def on_release(self, key, modifiers=None, msg=None):
        key = self._get_key(key)
        modifiers = self._get_modifiers(modifiers)
        K.toggle(key, False, modifiers)

