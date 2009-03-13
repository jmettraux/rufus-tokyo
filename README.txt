
= rufus-tokyo

ruby-ffi based interface to Tokyo Cabinet and Tokyo Tyrant.

The 'abstract' and the 'table' API are covered for now.


== installation

  sudo gem install rufus-tokyo

  (see after 'usage' for how to install Tokyo Cabinet (and Tyrant) if required)


== Rufus::Edo

Note : Rufus::Tokyo focuses on leveraging Hirabayashi-san's C libraries via ruby-ffi, but the gem rufus-tokyo also contains Rufus::Edo which wraps the Tokyo Cabinet/Tyrant author's [native] C bindings :

  http://github.com/jmettraux/rufus-tokyo/tree/master/lib/rufus/edo


== usage

hereafter TC references Tokyo Cabinet, while TT references Tokyo Tyrant.

the rdoc is at http://rufus.rubyforge.org/rufus-tokyo/


=== TC Abstract API

http://tokyocabinet.sourceforge.net/spex-en.html#tcadbapi

to create a hash (file named 'data.tch')

  require 'rubygems'
  require 'rufus/tokyo'

  db = Rufus::Tokyo::Cabinet.new('data.tch')

  db['nada'] = 'surf'

  p db['nada'] # => 'surf'
  p db['lost'] # => nil

  5000.times { |i| db[i.to_s] = "x" }

  p db.inject { |r, (k, v)| k } # => 4999

  db.close


=== TC Table API

http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

  require 'rubygems'
  require 'rufus/tokyo'

  t = Rufus::Tokyo::Table.new('table.tct')

  t['pk0'] = { 'name' => 'alfred', 'age' => '22' }
  t['pk1'] = { 'name' => 'bob', 'age' => '18' }
  t['pk2'] = { 'name' => 'charly', 'age' => '45' }
  t['pk3'] = { 'name' => 'doug', 'age' => '77' }
  t['pk4'] = { 'name' => 'ephrem', 'age' => '32' }

  p t.query { |q|
    q.add_condition 'age', :numge, '32'
    q.order_by 'age'
  }
    # => [ {"name"=>"ephrem", :pk=>"pk4", "age"=>"32"},
    #      {"name"=>"charly", :pk=>"pk2", "age"=>"45"} ]

  t.close

Note that the Tokyo Cabinet Table API does support transactions :

  p t.size
    # => 0

  t.transaction do
    t['pk0'] = { 'name' => 'alfred', 'age' => '22' }
    t['pk1'] = { 'name' => 'bob', 'age' => '18' }
    t.abort
  end

  p t.size
    # => 0


=== TT remote db

http://tokyocabinet.sourceforge.net/tyrantdoc/

to start a ttserver (backed by a hash), on the command line

  ttserver -port 45001 data.tch


then, in Ruby :

  require 'rubygems'
  require 'rufus/tokyo/tyrant'

  db = Rufus::Tokyo::Tyrant.new('localhost', 45001)

  db['nada'] = 'surf'

  p db['nada'] # => 'surf'
  p db['lost'] # => nil

  db.close


Rufus::Tokyo::Tyrant instances have a #stat method :

  puts db.stat.inject('') { |s, (k, v)| s << "#{k} => #{v}\n" }
    # =>
    #   pid => 7566
    #   loadavg => 0.398438
    #   size => 528736
    #   rnum => 0
    #   time => 1234764065.305923
    #   sid => 898521513
    #   type => hash
    #   bigend => 0
    #   ru_sys => 3.398698
    #   version => 1.1.15
    #   ru_user => 2.155215
    #   ru_real => 3218.451152
    #   fd => 7


Note that it's also OK to make a Tokyo Tyrant server listen on a unix socket :

  ttserver -host /tmp/ttsocket -port 0 data.tch

and then :

  require 'rubygems'
  require 'rufus/tokyo/tyrant'
  db = Rufus::Tokyo::Tyrant.new('/tmp/ttsocket')
  db['a'] = 'alpha'
  db.close


=== TT remote table

to start a ttserver (backed by a table), on the command line :

  ttserver -port 45002 data.tct


then, in Ruby, much like a local table :

  require 'rubygems'
  require 'rufus/tokyo/tyrant'

  t = Rufus::Tokyo::TyrantTable.new('localhost', 45002)

  t['pk0'] = { 'name' => 'alfred', 'age' => '22' }
  t['pk1'] = { 'name' => 'bob', 'age' => '18' }
  t['pk2'] = { 'name' => 'charly', 'age' => '45' }
  t['pk3'] = { 'name' => 'doug', 'age' => '77' }
  t['pk4'] = { 'name' => 'ephrem', 'age' => '32' }

  p t.query { |q|
    q.add_condition 'age', :numge, '32'
    q.order_by 'age'
  }
    # => [ {"name"=>"ephrem", :pk=>"pk4", "age"=>"32"},
    #      {"name"=>"charly", :pk=>"pk2", "age"=>"45"} ]

  t.close


Rufus::Tokyo::TyrantTable instances have a #stat method :

  puts t.stat.inject('') { |s, (k, v)| s << "#{k} => #{v}\n" }
    # =>
    #   pid => 7569
    #   loadavg => 0.295410
    #   size => 935792
    #   rnum => 0
    #   time => 1234764228.942014
    #   sid => 1027604232
    #   type => table
    #   bigend => 0
    #   ru_sys => 5.966750
    #   version => 1.1.15
    #   ru_user => 2.601947
    #   ru_real => 3382.084479
    #   fd => 10


Note that it's also OK to make a Tokyo Tyrant server listen on a unix socket :

  ttserver -host /tmp/tttsocket -port 0 data.tct

and then :

  require 'rubygems'
  require 'rufus/tokyo/tyrant'
  t = Rufus::Tokyo::TyrantTable.new('/tmp/tttsocket')
  t['customer0'] = { 'name' => 'Heike no Kyomori', 'age' => '75' }
  t.close


== rdoc

more in the rdoc

  http://rufus.rubyforge.org/rufus-tokyo/
  http://rufus.rubyforge.org/rufus-tokyo/classes/Rufus/Tokyo/Cabinet.html
  http://rufus.rubyforge.org/rufus-tokyo/classes/Rufus/Tokyo/Table.html
  http://rufus.rubyforge.org/rufus-tokyo/classes/Rufus/Tokyo/Tyrant.html
  http://rufus.rubyforge.org/rufus-tokyo/classes/Rufus/Tokyo/TyrantTable.html

don't hesitate to "man ttserver" on the command line.

or directly in the source

  http://github.com/jmettraux/rufus-tokyo/blob/master/lib/rufus/tokyo/cabinet/abstract.rb
  http://github.com/jmettraux/rufus-tokyo/blob/master/lib/rufus/tokyo/cabinet/table.rb
  http://github.com/jmettraux/rufus-tokyo/blob/master/lib/rufus/tokyo/tyrant/abstract.rb
  http://github.com/jmettraux/rufus-tokyo/blob/master/lib/rufus/tokyo/tyrant/table.rb


== Tokyo Cabinet / Tyrant install

a compilation of notes is available at :

  http://openwferu.rubyforge.org/tokyo.html


== dependencies

the ruby gem 'ffi'


== mailing list

On the rufus-ruby list :

  http://groups.google.com/group/rufus-ruby


== issue tracker

  http://rubyforge.org/tracker/?atid=18584&group_id=4812&func=browse


== irc

irc.freenode.net #ruote


== source

http://github.com/jmettraux/rufus-tokyo

  git clone git://github.com/jmettraux/rufus-tokyo.git


== credits

many thanks to the author of Tokyo Cabinet, Mikio Hirabayashi, and to the authors of ruby-ffi

  http://tokyocabinet.sourceforge.net
  http://kenai.com/projects/ruby-ffi


== authors

John Mettraux, jmettraux@gmail.com, http://jmettraux.wordpress.com
Zev Blut, http://www.iknow.co.jp/users/zev


== the rest of Rufus

http://rufus.rubyforge.org


== license

MIT

