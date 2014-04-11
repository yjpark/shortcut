import os
import logging
import sys

from core import shortcut_services_model as M

def is_compatable(m):
    # whitelist checked first
    platform_whitelist = getattr(m, 'platform_whitelist', None)
    if platform_whitelist is not None:
        logging.info('platform_whitelist = %s' % platform_whitelist)
        if sys.platform in platform_whitelist:
            return True
        else:
            return False
    # then checking blacklist
    platform_blacklist = getattr(m, 'platform_blacklist', None)
    if platform_blacklist is not None:
        logging.info('platform_blacklist = %s' % platform_blacklist)
        if sys.platform in platform_blacklist:
            return False
        else:
            return True

    return True

def discover_services_in_module(module):
    logging.info('discover_services_in_module: %s' % module)
    segs = module.split('.')
    m = __import__(module, globals, locals)
    for seg in segs[1:]:
        m = m.__getattribute__(seg)
    if not is_compatable(m):
        logging.info('skipped: not compatible with current platform')
        return
    for class_name in dir(m):
        logging.info('class name: %s' % class_name)
        if not class_name.endswith('Service'):
            continue
        if 'Abstract' in class_name:
            continue
        if 'Sub' in class_name:
            continue
        try:
            c = m.__getattribute__(class_name)
            service = M.model.create_service(c)
            logging.info('Service created: %s.%s, %s' % (module, c, service))
        except Exception, e:
            logging.error(module + '.' + class_name +
                          ' failed: %s' % e, exc_info=True)
            raise M.ShortcutServiceError(str(e))

def discover_services_in_directory(directory):
    for path, dirs, files in os.walk(directory, followlinks=True):
        module = path.replace('/', '.')
        for f in files:
            if f.endswith('_service.py'):
                discover_services_in_module(
                    '%s.%s' % (module, f.replace('.py', '')))

