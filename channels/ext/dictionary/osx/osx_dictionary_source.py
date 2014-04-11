import logging
import os
import pipes
import subprocess

from shortcut.channel import const as C

platform_whitelist = ['darwin']

TYPE = 'osx'
TITLE = 'OSX Dictionary'
DESCRIPTION = """You can lookup word definition through OSX's  builtin dictionary."""

busy = False

def lookup(word, channel=None, msg=None):
    global busy
    if not word:
        return {
            'source': TYPE,
            C.ERROR: 'Bad Parameter',
        }
    if busy:
        return {
            'source': TYPE,
            C.ERROR: 'Busy',
        }
    busy = True
    path = os.path.dirname(__file__)
    args = './lookup %s' % pipes.quote(word)
    #put them in list not working, the quote here is very important, otherwise
    #it will be very insecure to run arbitrary cmds here
    result = None
    try:
        f = subprocess.Popen(args=args, shell=True, cwd=path,
                             stdout=subprocess.PIPE)
        result = f.communicate()[0]
        result = {
            'source': TYPE,
            'word': word,
            'format': 'text',
            'definition': result,
        }
    except Exception, e:
        logging.error('Dictionary on_lookup error: %s' % e, exc_info=True)
        result = {
            'source': TYPE,
            C.ERROR: '%s' % e,
        }
    busy = False
    return result
