import logging
import os
import pipes
import subprocess
import urllib, urllib2

from BeautifulSoup import BeautifulSoup
from mako.template import Template

from shortcut.channel import const as C
from core import shortcut_channels_model as M
from ext.dictionary import dictionary_util as U
from shortcut import config as CFG

CMDS = {
    'set_default_source': {
        'source': C.STRING,
    },
    'lookup': {
        'word': C.STRING,
        'source': C.STRING,
    },
}

TYPES = {}

PROPERTIES = {
    'word': C.STRING,
    'definition': C.STRING,
}

TITLE = 'Dictionary'
DESCRIPTION = \
'You can lookup word definition, multiple source available through plugins'

from ext.dictionary.google_dictionary import google_dictionary_source as google
from ext.dictionary.dict_cn import dict_cn_dictionary_source as dictcn
from ext.dictionary.osx import osx_dictionary_source as osx

DEFAULT_SOURCE = CFG.get_config(CFG.EXT_SECTION, 'dictionary_default_source', default=osx.TYPE)
DEFAULT_LOOKUP = None
SOURCES_LOOKUP = {}
SOURCES_DICT = {}
SOURCES = []

for m in (dictcn, google, osx):
    if M.is_compatable(m):
        lookup = getattr(m, 'lookup')
        if lookup:
            SOURCES_LOOKUP[m.TYPE] = lookup
            SOURCES.append(m.TYPE)
            SOURCES_DICT[m.TYPE] = {
                C.TITLE: m.TITLE,
                C.DESCRIPTION: m.DESCRIPTION,
            }
        else:
            logging.critical('Bad Dictionary Source: %s' % m)

DEFAULT_LOOKUP = SOURCES_LOOKUP.get(DEFAULT_SOURCE, None)
if DEFAULT_LOOKUP is None:
    DEFAULT_SOURCE = SOURCES[0]
    DEFAULT_LOOKUP = SOURCES_LOOKUP.get(DEFAULT_SOURCE)

PROTOCOL = {
    C.TYPE: 'dictionary',
    C.TITLE: TITLE,
    C.DESCRIPTION: DESCRIPTION,
    C.CMDS: CMDS,
    C.TYPES: TYPES,
    C.PROPERTIES: PROPERTIES,
    C.ALLOW_HTTP_CONTROL: True,
    'default_source': DEFAULT_SOURCE,
    'sources': SOURCES,
    'sources_dict': SOURCES_DICT,
}

class DictionaryChannel(M.AbstractChannel):
    protocol = PROTOCOL

    def on_set_default_source(self, source, msg=None):
        logging.info('on_set_default_source: %s, current default source is: %s' % (source, DEFAULT_SOURCE))
        if source != DEFAULT_SOURCE:
            lookup = SOURCES_LOOKUP.get(source, None)
            if lookup:
                global DEFAULT_SOURCE, DEFAULT_LOOKUP
                DEFAULT_LOOKUP = lookup
                DEFAULT_SOURCE = source
                PROTOCOL['default_source'] = DEFAULT_SOURCE
                self.send_protocol()
                CFG.set_config(CFG.EXT_SECTION, 'dictionary_default_source', DEFAULT_SOURCE)
                CFG.save()
                logging.info('on_set_default_source: new default source is: %s' % DEFAULT_SOURCE)

        return {
            'default_source': DEFAULT_SOURCE
        }

    def on_lookup(self, word, source=None, msg=None):
        logging.info('on_lookup: [%s] - %s' % (source and source or DEFAULT_SOURCE, word))
        word = U.parse_word(word)
        if not word:
            return {
                C.ERROR: 'Bad Parameter',
            }
        lookup = SOURCES_LOOKUP.get(source, DEFAULT_LOOKUP)
        return lookup(word, channel=self, msg=msg)
