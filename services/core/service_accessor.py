import logging
from threading import Thread
from Queue import Queue
import urllib2

import tornado.escape

class SyncServiceAccessor():
    def __init__(self, service_address):
        self.service_address = service_address

    def access(self, args):
        logging.debug('Accessing: %s, %s' % (self.service_address, args))
        try:
            resp = urllib2.urlopen(self.service_address, data=tornado.escape.json_encode(args))
            resp = resp.readlines()
            logging.debug('Service = %s, args = %s, Response: %s' %
                           (self.service_address, args, '\n'.join(resp)))
        except Exception, e:
            logging.error('Service = %s, args = %s, Error: %s' % (self.service_address, args, e), exc_info=True)


class AsyncServiceAccessor():
    """
    NOT WORKING, USING GTK NOW
    """
    def __init__(self, service_address):
        self.service_address = service_address
        self.q = Queue()
        self.t = Thread(target=self.run)
        self.t.start()

    def run(self):
        while True:
            logging.error("-----------------------------------------")
            args = self.q.get()
            logging.debug('Accessing: %s, %s' % (self.service_address, args))
            try:
                resp = urllib2.urlopen(self.service_address, data=tornado.escape.json_encode(args))
                resp = resp.readlines()
                logging.debug('Service = %s, args = %s, Response: %s' %
                               (self.service_address, args, '\n'.join(resp)))
            except Exception, e:
                logging.error('Service = %s, args = %s, Error: %s' % (self.service_address, args, e), exc_info=True)
            self.q.task_done()

    def access(self, args, inQueueIfBusy=False):
        if self.q.qsize() <= 3:
            self.q.put(args)
        else:
            if inQueueIfBusy:
                self.q.put(args)
                logging.info('Adding request to a busy thread: %s, %s' % (self.service_address, args))
            else:
                logging.info('Dropping access due to busy thread: %s, %s' % (self.service_address, args))
