#!/bin/bash
cd /src;
source /home/app/perl5/perlbrew/etc/bashrc
source envfile.sh
perl script/daemon/Procobd start -f 1>>/data/log/Procobd.log 2>>/data/log/Procobd.error.log

