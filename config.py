#-*- coding:utf-8 -*-

from pipa_sources.basic import StupidCount
from pipa_sources.system import CpuUsage
from pipa_sources.openweathermap import OwmClient, OwmSource

### Data sources configuration

owm_toulouse = OwmClient("Toulouse,fr")

sources = [
    StupidCount("count", update_freq=10),
    CpuUsage("cpu"),
    OwmSource("tlse_temp", owm_toulouse, "main/celsius", unit="°C")
]

