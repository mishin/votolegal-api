#!/usr/bin/env bash

if [ -d "script" ]; then
  cd script;
fi

perl votolegal_create.pl model DB DBIC::Schema VotoLegal::Schema create=static components=TimeStamp,PassphraseColumn 'dbi:Pg:dbname=votolegal_dev;host=localhost' postgres 123mudar quote_names=1 overwrite_modifications=1

cd ..;

rm -f lib/VotoLegal/Model/DB.pm.new;
rm -f t/model_DB.t.new;
