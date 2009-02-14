#!/bin/bash

# stopping the spec ttservers

ruby -e "%w{ tmp/t_spec.pid tmp/tt_spec.pid }.each { |pf| File.exist?(pf) && Process.kill(9, File.read(pf).strip.to_i) }"

