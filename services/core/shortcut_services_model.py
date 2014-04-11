import logging

class ShortcutServiceError(Exception):
    pass


class AbstractService():
    pass


class ShortcutServicesModel(object):
    def __init__(self):
        self.services = []

    def create_service(self, _class):
        service = _class()
        self.services.append(service)
        return service

    def remove_service(self, service):
        self.services.remove(service)


# Singleton
model = ShortcutServicesModel()

