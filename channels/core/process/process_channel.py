import logging
import psutil
import socket

from shortcut.channel import const as C
from core import shortcut_channels_model as M

PID_TYPE = 'integer(min=1, max=999999)'

CMDS = {
    'list': {
    },
    'start': {
        'command': 'string()',
    },
    'kill': {
        'pid': PID_TYPE,
    },
    'detail': {
        'pid': PID_TYPE,
    },
    'global': {
    },
}

TYPES = {
    'processes': {
        C.TYPE: C.LIST,
        C.ITEM_TYPE: 'process',
    },
    'process': {
        C.TYPE: C.DICT,
        'pid': PID_TYPE,
        'name': C.STRING,
        'uid': C.INTEGER,
        'gid': C.INTEGER,
        'username': C.STRING,
        'command_line': {
            C.TYPE: C.LIST,
            C.ITEM_TYPE: C.STRING,
        },
        'path': C.STRING,
        'cpu': 'process_cpu',
        'mem': 'process_mem',
        'create_time': C.DATETIME,
    },
    'process_cpu': {
        C.TYPE: C.DICT,
        'percent': C.FLOAT,
        'user': C.FLOAT,
        'system': C.FLOAT,
    },
    'process_mem': {
        C.TYPE: C.DICT,
        'rss': C.LONG,
        'vms': C.LONG,
        'percent': C.FLOAT,
    },
    'global': {
        C.TYPE: C.DICT,
        'hostname': C.STRING,
        'cpu': 'global_cpu',
        'mem': 'global_mem',
    },
    'global_cpu': {
        'idle': C.FLOAT,
        'nice': C.FLOAT,
        'system': C.FLOAT,
        'user': C.FLOAT,
        'percent': C.FLOAT,
    },
    'global_mem': {
        'used_physical': C.LONG,
        'used_virtual': C.LONG,
        'available_physical': C.LONG,
        'available_virtual': C.LONG,
    },
}

PROPERTIES = {
    'all_processes': 'processes',
    'user_processes': 'processes',
    'global': 'global',
}

TITLE = 'Process Moniter/Controller'
DESCRIPTION = \
'You can watch the processes that running in the system, and you can also ' \
'control them in certain ways.'

PROTOCOL = {
    C.TYPE: 'process',
    C.TITLE: TITLE,
    C.DESCRIPTION: DESCRIPTION,
    C.CMDS: CMDS,
    C.TYPES: TYPES,
    C.PROPERTIES: PROPERTIES,
}

class ProcessChannel(M.AbstractChannel):
    protocol = PROTOCOL

    def on_global(self, msg=None):
        global_cpu = psutil.get_system_cpu_times()
        global_cpu['percent'] = psutil.cpu_percent()
        global_mem = {
            'used_physical': psutil.used_phymem(),
            'used_virtual': psutil.used_virtmem(),
            'available_physical': psutil.avail_phymem(),
            'available_virtual': psutil.avail_virtmem(),
        }
        result = {
            'hostnome': socket.gethostname(),
            'cpu': global_cpu,
            'mem': global_mem,
        }
        return {'global': result}

    def get_process(self, pid):
        p = psutil.Process(pid)
        process_cpu = {}
        process_mem = {}
        try:
            user, system = p.get_cpu_times()
            process_cpu['user'] = user
            process_cpu['system'] = system
            process_cpu['percent'] = p.get_cpu_percent()
            rss, vms = p.get_memory_info()
            process_mem['rss'] = rss
            process_mem['vms'] = vms
            process_mem['percent'] = p.get_memory_percent()
        except Exception, e:
            logging.critical('Get cpu/mem error: %s' % e, exc_info=True)
            pass # most likely lacking permission for other users' processes
        process = {
            'pid': pid,
            'name': p.name,
            'uid': p.uid,
            'gid': p.gid,
            'username': self.get_username(p),
            'command_line': p.cmdline,
            'path': p.path,
            'cpu': process_cpu,
            'mem': process_mem,
            'create_time': p.create_time,
        }
        return process

    def get_username(self, p):
        username = getattr(p, "username", None)
        if username is None:
            try:
                import pwd
                username = pwd.getpwuid(p.uid).pw_name
            except Exception, e:
                logging.debug('Failed to get username: %s' % e, exc_info=True)
                username = 'n/a'
        return username

    def on_detail(self, pid, msg=None):
        return {'process': self.get_process(pid)}

    def on_list(self, msg=None):
        processes = []
        for pid in psutil.get_pid_list():
            processes.append(self.get_process(pid))
        return {
            'processes': processes,
        }

