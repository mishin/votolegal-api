#!/bin/bash

VOTOLEGAL_API_PORT="8105"
VOTOLEGAL_API_WORKERS="4"

STARMAN_BIN="$(which starman)"
DAEMON="$(which start_server)"
GIT_DIR=$(git rev-parse --show-toplevel)

line (){
    perl -e "print '-' x 40, $/";
}

mkdir -p $GIT_DIR/log/

up_server (){
    PSGI_APP_NAME="$1"
    PORT="$2"
    WORKERS="$3"

    ERROR_LOG="$GIT_DIR/log/votolegal.error.log"
    STATUS="$GIT_DIR/log/votolegal.start_server.status"
    PIDFILE="$GIT_DIR/log/votolegal.start_server.pid"

    touch $ERROR_LOG
    touch $PIDFILE
    touch $STATUS

    STARMAN="$STARMAN_BIN -I$GIT_DIR/lib --preload-app --workers $WORKERS $GIT_DIR/$PSGI_APP_NAME"

    DAEMON_ARGS=" --pid-file=$PIDFILE --signal-on-hup=QUIT --status-file=$STATUS --port $PORT -- $STARMAN"

    echo "Restarting...  $DAEMON --restart $DAEMON_ARGS"
    $DAEMON --restart $DAEMON_ARGS

    if [ $? -gt 0 ]; then
        echo "Restart failed, application likely not running. Starting..."

        echo "/sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER -u $USER --exec $DAEMON --$DAEMON_ARGS"
        /sbin/start-stop-daemon -b --start --pidfile $PIDFILE --chuid $USER -u $USER --exec $DAEMON --$DAEMON_ARGS
    fi
}

: ${SQITCH_DEPLOY:=local}
sqitch deploy -t $SQITCH_DEPLOY

export DBIC_TRACE=0

echo "Restaring server...";
up_server "votolegal.psgi" $VOTOLEGAL_API_PORT $VOTOLEGAL_API_WORKERS

line

# Daemons.
./script/daemon/Emailsd restart

line
echo "sleeping 5..."
sleep 5
./script/daemon/Emailsd status
