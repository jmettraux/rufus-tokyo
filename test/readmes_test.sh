#!/bin/bash

#
# testing the 4 samples in README.txt
#

[ -d tmp ] || mkdir tmp
nohup ttserver -port 45001 tmp/data.tch &
nohup ttserver -port 45002 tmp/data.tct &

ruby19 -Ilib test/readme0.rb
ruby19 -Ilib test/readme1.rb
ruby19 -Ilib test/readme2.rb
ruby19 -Ilib test/readme3.rb

killall ttserver

