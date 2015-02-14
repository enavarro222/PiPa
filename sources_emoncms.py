#-*- coding:utf-8 -*-
import logging
import gevent

from sources import AutoUpdateValue
import emoncms

class EmoncmsSource(AutoUpdateValue):
    update_freq = 30 # every minutes by default

    def __init__(self, name, emoncms, feedid, unit=None, update_freq=None):
        self.emoncms = emoncms
        self.feedid = feedid
        super(EmoncmsSource, self).__init__(name=name, unit=unit, update_freq=update_freq)

    def update(self):
        values = self.emoncms.get_value(self.feedid)
        self.value = float(values["value"])
        return values["date"]

