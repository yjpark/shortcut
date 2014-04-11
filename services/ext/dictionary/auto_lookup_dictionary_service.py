import logging
import sys
from shortcut import config as C
from core.service_accessor import SyncServiceAccessor, AsyncServiceAccessor
from core import shortcut_services_model as M

platform_whitelist = []
try:
    import gtk
    platform_whitelist.append(sys.platform)
except Exception, e:
    pass

class LookupDictionaryService(M.AbstractService):
    def __init__(self):
        self.processing = False
        self.lastWord = None
        dict_service_address = C.get_config(C.EXT_SECTION, 'lookup_dictionary_service_address')
        self.dict_service_accessor = None
        if dict_service_address:
            self.dict_service_accessor = SyncServiceAccessor(dict_service_address)
            self.clip = gtk.clipboard_get(gtk.gdk.SELECTION_PRIMARY)
            self.clip.connect('owner-change', self.lookup_in_dictionary)
            logging.info('LookupDictionaryService: start listening to selection clipboard')
        else:
            logging.error('Bad dictionary service address %s', dict_service_address)

    def lookup_in_dictionary(self, clipboard, event):
        if self.processing:
            return
        self.processing = True
        word = clipboard.wait_for_text()
        if not word or (len(word) > 50) or (self.lastWord == word):
            self.processing = False
            return

        self.lastWord = word
        logging.info('lookup_in_dictionary: %s' % word)
        if self.dict_service_accessor:
            args = {
                'word': word,
            }
            self.dict_service_accessor.access(args)
        self.processing = False


