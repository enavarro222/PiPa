#!/usr/bin/env python
#-*- coding:utf-8 -*-
import sys

from flask import Flask
from flask import render_template
from flask.ext.socketio import SocketIO
from flask.ext.socketio import emit

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

@app.route("/inc")
def inc():
    model["value"] += 1
    socketio.emit('update', model, namespace='/model')
    return "ok"

@socketio.on('connect', namespace='/model')
def test_connect():
    print "Connected !!"
    emit('Connected', {'data': 'Connected'})


if __name__ == '__main__':
    socketio.run(app)    ## run the app


