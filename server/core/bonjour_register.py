import logging
import select
import sys
import pybonjour

regtype = '_pettyfun-shortcut._tcp.'

def register_callback(sdRef, flags, errorCode, name, regtype, domain):
    logging.info('Register service callback: name = %s, regtype = %s, '
                 'domain = %s, flags = %s, errorCode = %s, sdRef = %s'
                  % (name, regtype, domain, flags, errorCode, sdRef))
    if errorCode == pybonjour.kDNSServiceErr_NoError:
        logging.info('Registered successfully: name = %s, regtype = %s, '
                         'domain = %s' % (name, regtype, domain))

def register(name, port):
    sdRef = pybonjour.DNSServiceRegister(name=name,
                                         regtype=regtype,
                                         port=port,
                                         callBack=register_callback)

    try:
        ready = select.select([sdRef], [], [])
        if sdRef in ready[0]:
            pybonjour.DNSServiceProcessResult(sdRef)
    except Exception, e:
        logging.critical('Error registering bonjour service: %s' % e,
                         exc_info=True)
