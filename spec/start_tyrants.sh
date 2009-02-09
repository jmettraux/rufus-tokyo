#!/bin/bash

ttserver \
  -dmn \
  -port 45000 \
  -pid tmp/t_spec.pid -rts tmp/t_spec.rts \
  -log tmp/t.log \
  tmp/tyrant.tch

ttserver \
  -dmn \
  -port 45001 \
  -pid tmp/tt_spec.pid -rts tmp/tt_spec.rts \
  -log tmp/tt.log \
  tmp/tyrant_table.tct

