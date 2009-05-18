
require 'rubygems'

require 'rufus/scheduler'
require 'rufus/tokyo/tyrant'
require 'rufus/edo/ntyrant'

SCHEDULER = Rufus::Scheduler.start_new

FFI_TABLE = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 45001)
NET_TABLE = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)

def check_connection (table)
  p [ table.class, table.stat ]
end

$interval = 0

BLOCK = lambda {
  puts "=== #{Time.now}"
  check_connection(FFI_TABLE)
  check_connection(NET_TABLE)
  $interval = $interval + 1
  SCHEDULER.in("#{$interval}h", &BLOCK)
}

BLOCK.call

SCHEDULER.join

