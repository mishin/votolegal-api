#!/bin/bash
cd /src;
source /home/app/perl5/perlbrew/etc/bashrc
source envfile.sh
perl script/daemon/Blockchaind start -f 1>>/data/log/Blockchaind.log 2>>/data/log/Blockchaind.error.log

