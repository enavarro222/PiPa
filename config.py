#-*- coding:utf-8 -*-
from emoncms import EmoncmsClient

from sources import StupidCount, CpuUsage
from sources_emoncms import EmoncmsSource

### Data sources configuration

sources = [
    StupidCount("count", update_freq=10),
    CpuUsage("cpu"),
]

