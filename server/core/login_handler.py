import logging
import tornado

USER_COOKIE_NAME = 'shortcut_user'

class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        logging.debug('user: %s' % self.get_secure_cookie(USER_COOKIE_NAME))
        return self.get_secure_cookie(USER_COOKIE_NAME)

    def post(self):
        raise M.ShortcutServerError('Access denied.')


class LoginHandler(tornado.web.RequestHandler):
    def get(self):
        next = self.get_argument('next', '/')
        self.write('<html><body><form action="/login" method="post">'
                   'Name: <input type="text" name="user_name">'
                   '<input type="hidden" name="next" value="%s"'
                   '<input type="submit" value="Sign in">'
                   '</form></body></html>' % next)

    def post(self):
        self.set_secure_cookie(USER_COOKIE_NAME, self.get_argument('user_name'))
        logging.info('user logged in: %s' % self.get_secure_cookie(USER_COOKIE_NAME))
        next = self.get_argument('next', '/')
        self.redirect(next)

