import os
import logging
import sys
import urlparse

from core import shortcut_channels_model as M

#older version of urlparse is not handling unknown scheme well
if 'wss' not in urlparse.uses_netloc:
    urlparse.uses_netloc.append('wss')

def discover_channels_in_module(url, auth_code, module):
    logging.info('discover_channels_in_module: %s' % module)
    segs = module.split('.')
    m = __import__(module, globals, locals)
    for seg in segs[1:]:
        m = m.__getattribute__(seg)
    if not M.is_compatable(m):
        logging.info('skipped: not compatible with current platform')
        return
    for class_name in dir(m):
        logging.info('class name: %s' % class_name)
        if not class_name.endswith('Channel'):
            continue
        if 'Abstract' in class_name:
            continue
        if 'Sub' in class_name:
            continue
        try:
            c = m.__getattribute__(class_name)
            channel = M.model.create_channel(url, auth_code, c)
            logging.info('Channel created: %s.%s, %s' % (module, c, channel))
        except Exception, e:
            logging.error(module + '.' + class_name +
                          ' failed: %s' % e, exc_info=True)
            raise M.ShortcutChannelError(str(e))

def discover_channels_in_directory(url, auth_code, directory):
    for path, dirs, files in os.walk(directory, followlinks=True):
        module = path.replace('/', '.')
        for f in files:
            if f.endswith('_channel.py'):
                discover_channels_in_module(url, auth_code,
                    '%s.%s' % (module, f.replace('.py', '')))

