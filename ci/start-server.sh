#!/bin/bash
export WORKERS=4

source /home/app/perl5/perlbrew/etc/bashrc

mkdir -p /data/log/;

cd /src;
source envfile.sh

cpanm -n . --installdeps
sqitch deploy -t $SQITCH_DEPLOY

start_server \
  --pid-file=/tmp/start_server.pid \
  --signal-on-hup=QUIT \
  --kill-old-delay=10 \
  --port=8080 \
  -- starman \
  -I/src/lib \
  --max-requests 100000 \
  --workers $WORKERS \
  --error-log /data/log/starman.log \
  --user app --group app votolegal.psgi

