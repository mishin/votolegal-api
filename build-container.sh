#!/usr/bin/env bash
cp Makefile.PL docker/Makefile_local.PL
docker build -t appcivico/votolegal docker/
rm -f docker/Makefile_local.PL
