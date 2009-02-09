#!/bin/bash

#
# starting the tt servers (standard + table)
#

TMP=`pwd`/tmp
  # so that tt doesn't complain about relative paths...

ttserver \
  -dmn \
  -port 45000 \
  -pid $TMP/t_spec.pid -rts $TMP/t_spec.rts \
  -log $TMP/t.log \
  $TMP/tyrant.tch

ttserver \
  -dmn \
  -port 45001 \
  -pid $TMP/tt_spec.pid -rts $TMP/tt_spec.rts \
  -log $TMP/tt.log \
  $TMP/tyrant_table.tct

