#!/usr/bin/env python
#-*- coding:utf-8 -*-
import sys

from flask import Flask
from flask import render_template
from flask.ext.socketio import SocketIO
from flask.ext.socketio import emit

import gevent

## Build the app
app = Flask(__name__)
app.debug = True
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

@app.route("/")
def index():
    return render_template('index.html')

model = {
    "value": 0,
}



@app.route("/model/reset")
def model_reset():
    model["value"] = 0
    socketio.emit('update', model, namespace='/model')
    return "ok"

@app.route("/model/inc")
def model_inc():
    model["value"] += 1
    socketio.emit('update', model, namespace='/model')
    return "ok"

@socketio.on('connect', namespace='/model')
def test_connect():
    print "Connected !!"
    emit('Connected', {'data': 'Connected'})


def auto_inc():
    while True:
        model_inc()
        gevent.sleep(1)


if __name__ == '__main__':
    auto_inc_worker = gevent.spawn(auto_inc)
    socketio.run(app, host="0.0.0.0", port=5005)

