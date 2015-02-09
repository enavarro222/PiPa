#-*- coding:utf-8 -*-
import logging
from datetime import datetime

import gevent

class DataSource(object):
    """ Abstract data source model
    """
    def __init__(self, name):
        self.name = name
        self.callbacks = []
        self._logger = logging.getLogger(self.name)

    def on_change(self, callback):
        self.callbacks.append(callback)

    def changed(self):
        for callback in self.callbacks:
            callback()

    def start(self):
        pass

    def export(self):
        return {
            "name": self.name,
        }

    def desc(self):
        return {
            "type": self.__class__.__name__,
            "name": self.name,
        }


class AutoUpdateValue(DataSource):
    """ Basic value source model: 
    * a single value (with a label and a unit)
    * an update methode called every N seconds
    """
    unit = ""
    update_freq = 1     # frequence of update

    def __init__(self, name, unit=None, update_freq=None):
        super(AutoUpdateValue, self).__init__(name=name)
        self.worker = None
        self._value = 0
        self._error = None
        self.last_update = None
        if unit is not None:
            self.unit = unit
        if update_freq is not None:
            self.update_freq = update_freq or AutoUpdateValue.update_freq
        self.prevous_update = None
        self.last_update = None
        self.checked_update()

    @property
    def value(self):
        return self._value

    @value.setter
    def value(self, val):
        self._value = val

    @property
    def error(self):
        return self._error

    @error.setter
    def error(self, val):
        self._error = val

    def update(self):
        """ Abstract update method
        
        Returns None or the last date of the setted value
        """
        return None

    def checked_update(self):
        try:
            last_update = self.update()
            self.error = None
            if last_update is None:
                last_update = datetime.now()
            self.prevous_update = self.last_update
            self.last_update = last_update
            if self.last_update != self.prevous_update:
                self.changed()
        except Exception as err:
            self.error = "Error"
            self.changed()
            self._logger.error("update error: %s" % err)

    def update_work(self):
        while True:
            self._logger.info("Update !")
            self.checked_update()
            gevent.sleep(self.update_freq)

    def start(self):
        self.worker = gevent.spawn(self.update_work)

    def export(self):
        res = super(AutoUpdateValue, self).export()
        res["value"] = self.value
        res["unit"] = self.unit
        res["error"] = self.error
        res["last_update"] = self.last_update.isoformat()
        return res


class StupidCount(AutoUpdateValue):
    unit = ""
    update_freq = 1

    def update(self):
        self.value += 1

class CpuUsage(AutoUpdateValue):
    unit = "%"
    update_freq = 1.9

    def update(self):
        import psutil
        self.value = psutil.cpu_percent(interval=0)

