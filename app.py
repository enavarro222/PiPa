#!/usr/bin/env python
#-*- coding:utf-8 -*-
import sys
import logging

from flask import Flask
from flask import render_template, jsonify
from flask.ext.socketio import SocketIO
from flask.ext.socketio import emit

from emoncms import EmoncmsClient

from sources import StupidCount, CpuUsage
from sources_emoncms import EmoncmsSource

## manage emoncms data source
with open("emonsrc_config.txt") as emoncfg:
    url = emoncfg.readline().strip()
    key = emoncfg.readline().strip()
    emoncms_beytan = EmoncmsClient(url, key)

# data source configuration
sources = [
    StupidCount("count", update_freq=10),
    CpuUsage("cpu"),
    EmoncmsSource("ext_temp", emoncms_beytan, feedid=34, unit="°C"),
    EmoncmsSource("grange_temp", emoncms_beytan, feedid=40, unit="°C"),
]

logger = logging.getLogger()

# index of sources by name
source_idx = {
    src.name: src for src in sources
}

## Build the app
app = Flask(__name__)
app.debug = True
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

@app.route("/")
def index():
    return render_template('index.html')


@app.route("/source")
def sources_list():
    res = {}
    res["nb"] = len(sources)
    res["sources"] = [src.desc() for src in sources]
    return jsonify(res)


@app.route("/source/<source>")
def source_get(source):
    src = source_idx[source]
    res = src.export()
    return jsonify(res)

def register_source(src):
    namespace = '/source/'+src.name

    def change_callback():
        socketio.emit('update', src.export(), namespace=namespace)
    src.on_change(change_callback)

    def on_connect():
        print "Connected to %s" % namespace
        emit('Connected', src.desc())
    socketio.on('connect', namespace=namespace)(on_connect)

# plug change callback
for src in sources:
    register_source(src)

# run sources
for src in sources:
    src.start()

if __name__ == '__main__':
    ## logger
    level = logging.DEBUG
    logger.setLevel(level)
    # create console handler with a higher log level
    ch = logging.StreamHandler()
    ch.setLevel(level)
    # create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s:%(levelname)s:%(name)s:%(message)s')
    ch.setFormatter(formatter)
    # add the handlers to the logger
    logger.addHandler(ch)

    socketio.run(app, host="0.0.0.0", port=5005)

