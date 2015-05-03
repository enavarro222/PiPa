#!/bin/bash
## Run CILLEX throw gunicorn

#set -x  #log all execed lin for debug
set -e
BASEDIR=/home/pi/pipa/
APPMODULE=pipa
APPNAME=app

# log
LOGFILE=$BASEDIR/log/pipa.log 
LOGDIR=$(dirname $LOGFILE)
LOGLEVEL=debug

# gunicorn config
BIND=0.0.0.0:8000
NUM_WORKERS=1

# user/group to run as
USER=pi
GROUP=pi

# export config for matplotlib
export MPLCONFIGDIR=/tmp

## start the app
cd $BASEDIR
# if  virtualenv is used 
source ./pipavenv/bin/activate

#pre-start script
# create log dir if not exist
test -d $LOGDIR || mkdir -p $LOGDIR
#end script

# run the gunicorn server
exec gunicorn --worker-class socketio.sgunicorn.GeventSocketIOWorker\
    --workers $NUM_WORKERS --bind=$BIND\
    --user=$USER --group=$GROUP --log-level=$LOGLEVEL \
    --log-file=$LOGFILE $APPMODULE:$APPNAME #2>>$LOGFILE
