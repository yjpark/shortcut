import logging
import os
import pipes
import subprocess
import urllib, urllib2

from BeautifulSoup import BeautifulSoup
from mako.template import Template

from shortcut.channel import const as C
from shortcut import config as CFG
from core import shortcut_channels_model as M

TYPE = 'google.dictionary'
TITLE = 'Google Dictionary'
DESCRIPTION = \
'You can lookup word definition through google dictionary.'

busy = False
busy_req_count = 0

def get_url(word):
    lang = CFG.get_config(CFG.EXT_SECTION, 'dictionary_google_langpair', default='en|zh-CN')
    url = 'http://www.google.com/dictionary?aq=f&langpair=%s&hl=en&q=%s' % \
          (lang, urllib.quote(word))
    return url

def lookup_google_on_device(word, channel=None, msg=None):
    global busy, busy_req_count
    url = get_url()
    try:
        data = {
            'word': word,
            'format': 'url',
            'definition': url,
        }
    except Exception, e:
        logging.error('Dictionary on_lookup error: %s' % e, exc_info=True)
        data = {
            C.ERROR: '%s' % e,
        }
    busy = False
    busy_req_count = 0
    return data

@M.threaded()
def lookup_google(word, channel=None, msg=None):
    global busy, busy_req_count
    url = get_url(word)
    try:
        resp = urllib2.urlopen(url)
        result = resp.readlines()
        result = '\n'.join(result)
        """
        xml = BeautifulSoup(result)
        template = Template(filename='%s%sdict_cn_result.html' %
                           (os.path.dirname(__file__), os.path.sep),
                            output_encoding='utf-8',
                            encoding_errors='replace')
        html = template.render(data=xml)
        """
        html = result
        data = {
            'source': TYPE,
            'word': word,
            'format': 'html',
            'url': url,
            'definition': html,
        }
        audio = None
        if audio:
            data['audio'] = audio.string
        logging.info('God Result: %s [%s]' % (word, len(result)))
    except Exception, e:
        logging.error('Dictionary on_lookup error: %s' % e, exc_info=True)
        data = {
            'source': TYPE,
            C.ERROR: '%s' % e,
        }
    channel.send_notify(data, original_msg=msg, from_thread=True)
    busy = False
    busy_req_count = 0
    return data

def lookup(word, channel=None, msg=None):
    global busy, busy_req_count
    if not word:
        return {
            'source': TYPE,
            C.ERROR: 'Bad Parameter',
        }
    if busy:
        busy_req_count += 1
        if busy_req_count <= 3:
            return {
                'source': TYPE,
                C.ERROR: 'Busy',
            }
        else:
            busy_req_count = 0
    busy = True
    lookup_google(word, channel=channel, msg=msg)
    return None
