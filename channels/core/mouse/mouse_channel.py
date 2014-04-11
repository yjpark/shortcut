import logging
import autopy

from shortcut.channel import const as C
from core import shortcut_channels_model as M

BUTTON_TYPE = 'integer(min=1, max=3)'

BUTTON_TYPES = {
    1: autopy.mouse.LEFT_BUTTON,
    2: autopy.mouse.RIGHT_BUTTON,
    3: autopy.mouse.CENTER_BUTTON,
}

CMDS = {
    'screen_size': {
    },
    'position': {
    },
    'relative_move': {
        'x': C.INTEGER,
        'y': C.INTEGER,
    },
    'move': {
        'x': C.INTEGER,
        'y': C.INTEGER,
    },
    'smooth_move': {
        'x': C.INTEGER,
        'y': C.INTEGER,
    },
    'double_click': {
    },
    'click': {
        'button': BUTTON_TYPE,
    },
    'press': {
        'button': BUTTON_TYPE,
    },
    'release': {
        'button': BUTTON_TYPE,
    },
}

TYPES = {
    'screen_size': {
        C.TYPE: C.DICT,
        'x': C.INTEGER,
        'y': C.INTEGER,
    },
    'position': {
        C.TYPE: C.DICT,
        'x': C.INTEGER,
        'y': C.INTEGER,
    },
}

PROPERTIES = {
    'screen_size': 'screen_size',
    'position': 'position',
}

TITLE = 'Mouse Controller'
DESCRIPTION = \
'You can simulate mouse movement and button click.'

PROTOCOL = {
    C.TYPE: 'mouse',
    C.TITLE: TITLE,
    C.DESCRIPTION: DESCRIPTION,
    C.CMDS: CMDS,
    C.TYPES: TYPES,
    C.PROPERTIES: PROPERTIES,
}

class MouseChannel(M.AbstractChannel):
    protocol = PROTOCOL

    def on_screen_size(self, msg=None):
        x, y = autopy.screen.get_size()
        result = {
            'x': x,
            'y': y,
        }
        return {'screen_size': result}

    def on_position(self, msg=None):
        x, y = autopy.mouse.get_pos()
        result = {
            'x': x,
            'y': y,
        }
        return {'position': result}

    def move(self, x, y, smooth=False):
        screen_x, screen_y = autopy.screen.get_size()
        x = min(max(x, 0), screen_x - 1)
        y = min(max(y, 0), screen_y - 1)
        if smooth:
            autopy.mouse.smooth_move(x, y)
        else:
            autopy.mouse.move(x, y)

    def on_relative_move(self, x, y, msg=None):
        now_x, now_y = autopy.mouse.get_pos()
        self.move(int(x) + now_x, int(y) + now_y)
        return self.on_position()

    def on_move(self, x, y, msg=None):
        self.move(x, y)
        return self.on_position()

    def on_smooth_move(self, x, y):
        self.move(x, y, smooth=True)
        return self.on_position()

    def _get_button(self, button):
        result = BUTTON_TYPES.get(int(button), autopy.mouse.LEFT_BUTTON)
        return result

    def on_double_click(self, msg=None):
        self.on_click(1)
        time.sleep(0.1)
        self.on_click(1)

    def on_click(self, button, msg=None):
        button = self._get_button(button)
        autopy.mouse.click(button)

    def on_press(self, button, msg=None):
        button = self._get_button(button)
        autopy.mouse.toggle(True, button)

    def on_release(self, button, msg=None):
        button = self._get_button(button)
        autopy.mouse.toggle(False, button)

