import logging
import socket
import tornado

from core import login_handler
from core import shortcut_server_model as M

class HomeHandler(login_handler.BaseHandler):
    """
    This handler is to showing the home page of the server 
    """
    @tornado.web.authenticated
    def get(self):
        data = {
            'title': 'Shortcut Server: %s' % socket.gethostname(),
            'channels': M.model.channels,
            'connections': M.model.connections,
        }
        self.render('home.html', **data)


class ConsoleHandler(login_handler.BaseHandler):
    """
    This handler is to display a console page for debugging/monitoring
    """
    @tornado.web.authenticated
    def get(self):
        data = {
            'title': 'Shortcut Console: %s' % socket.gethostname(),
            'channels': M.model.channels,
        }
        self.render('console.html', **data)

