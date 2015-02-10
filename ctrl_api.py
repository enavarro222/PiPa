#-*- coding:utf-8 -*-
import os
import subprocess

from flask import Blueprint
from flask import jsonify, abort

api = Blueprint('ctrl_api', __name__)

@api.route('/screen/on')
def screen_on():
    #os.system("utils/screen_on.sh")
    #os.system("xrefresh -d :0.0")
    subprocess.call("utils/screen_on.sh", shell=True)
    res = {
        "state": "on",
    }
    return jsonify(res)


@api.route('/screen/off')
def screen_off():
    os.system("utils/screen_off.sh")
    res = {
        "state": "off",
    }
    return jsonify(res)

