#!/bin/bash

#
# testing the 4 samples in README.txt
#

[ -d tmp ] || mkdir tmp

jruby -Ilib test/readme0.rb
jruby -Ilib test/readme1.rb
jruby -Ilib test/readme2.rb
jruby -Ilib test/readme3.rb

#killall ttserver

