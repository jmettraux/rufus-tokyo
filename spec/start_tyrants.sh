#!/bin/bash

#
# starting the tt servers (standard + table)
#

TMP=`pwd`/tmp
  # so that tt doesn't complain about relative paths...

[ -d $TMP ] || mkdir $TMP

ttserver \
  -dmn \
  -ext `pwd`/spec/incr.lua \
  -port 45000 \
  -pid $TMP/t_spec.pid -rts $TMP/t_spec.rts \
  -log $TMP/t.log \
  -unmask copy \
  $TMP/tyrant.tch

ttserver \
  -dmn \
  -ext `pwd`/spec/incr.lua \
  -port 45001 \
  -pid $TMP/tt_spec.pid -rts $TMP/tt_spec.rts \
  -log $TMP/tt.log \
  $TMP/tyrant_table.tct

