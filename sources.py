#-*- coding:utf-8 -*-
import logging
import gevent

class DataSource(object):
    """ Abstract data source model
    """
    def __init__(self, name):
        self.name = name
        self.callbacks = []
        self._logger = logging.getLogger()

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
    label = "value"
    icon = ""

    update_freq = 1     # frequence of update

    def __init__(self, name, unit=None, label=None, update_freq=None):
        super(AutoUpdateValue, self).__init__(name=name)
        self._value = 0
        self.worker = None
        if unit is not None:
            self.unit = unit
        if label is not None:
            self.label = label
        if update_freq is not None:
            self.update_freq = update_freq or AutoUpdateValue.update_freq
        self.update()

    def update(self):
        """ Abstract update method
        """
        pass

    @property
    def value(self):
        return self._value

    @value.setter
    def value(self, val):
        self._value = val
        self.changed()

    def auto_update(self):
        while True:
            self.update()
            gevent.sleep(self.update_freq)

    def start(self):
        self.worker = gevent.spawn(self.auto_update)

    def export(self):
        res = super(AutoUpdateValue, self).export()
        res["value"] = self.value
        res["unit"] = self.unit
        return res


class StupidCount(AutoUpdateValue):
    unit = ""

    def update(self):
        self.value += 1

class CpuUsage(AutoUpdateValue):
    unit = "%"
    update_freq = 1.9

    def update(self):
        import psutil
        self.value = psutil.cpu_percent(interval=0)

