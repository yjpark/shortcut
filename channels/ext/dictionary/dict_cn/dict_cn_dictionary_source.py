import logging
import os
import pipes
import subprocess
import urllib, urllib2

from BeautifulSoup import BeautifulSoup
from mako.template import Template

from shortcut.channel import const as C
from core import shortcut_channels_model as M

TYPE = "dict.cn"
TITLE = 'dict.cn Dictionary'
DESCRIPTION = \
'You can lookup word definition through dict.cn.'

busy = False
busy_req_count = 0

@M.threaded()
def lookup_dict_cn(word, channel=None, msg=None):
    global busy, busy_req_count
    url = 'http://dict.cn/ws.php?utf8=true&q=%s' % urllib.quote(word)
    try:
        resp = urllib2.urlopen(url)
        result = resp.readlines()
        result = '\n'.join(result)
        xml = BeautifulSoup(result)
        template = Template(filename='%s%sdict_cn_result.html' %
                           (os.path.dirname(__file__), os.path.sep),
                            output_encoding='utf-8',
                            encoding_errors='replace')
        html = template.render(data=xml)
        data = {
            'source': TYPE,
            'word': word,
            'format': 'html',
            'url': 'http://dict.cn/',
            'definition': html,
        }
        audio = xml.dict.audio
        if audio:
            data['audio'] = audio.string
    except Exception, e:
        logging.error('Dictionary on_lookup error: %s' % e, exc_info=True)
        data = {
            'source': TYPE,
            C.ERROR: '%s' % e,
        }
    channel.send_notify(data, original_msg=msg, from_thread=True)
    busy = False
    busy_req_count = 0

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
    lookup_dict_cn(word, channel=channel, msg=msg)
    return None
