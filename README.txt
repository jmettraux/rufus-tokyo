
= rufus-tokyo

ruby-ffi based interface to Tokyo Cabinet and Tokyo Tyrant.

The 'abstract' and the 'table' API are covered for now.


== installation

  sudo gem install rufus-tokyo

  (see after 'usage' for how to install Tokyo Cabinet (and Tyrant) if required)


== usage

hereafter TC references Tokyo Cabinet, while TT references Tokyo Tyrant.


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
  
  t = Rufus::Tokyo::Table.new('table.tdb', :create, :write)
  
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

=== TT remote db

http://tokyocabinet.sourceforge.net/tyrantdoc/

to start a ttserver (backed by a hash), on the command line

  ttserver -port 45001 data.tch


then, in Ruby :

  require 'rubygems'
  require 'rufus/tokyo'

  db = Rufus::Tokyo::Tyrant.new('tyrant.example.com', 45001)

  db['nada'] = 'surf'

  p db['nada'] # => 'surf'
  p db['lost'] # => nil

  db.close


=== TT remote table

to start a ttserver (backed by a table), on the command line :

  ttserver -port 45006 data.tct


then, in Ruby, much like a local table :

  require 'rubygems'
  require 'rufus/tokyo'
  
  t = Rufus::Tokyo::TyrantTable.new('localhost', 45006)
  
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

I compiled some notes about that at :

  http://openwferu.rubyforge.org/tokyo.html


== dependencies

  the ruby gem ffi


== mailing list

On the rufus-ruby list[http://groups.google.com/group/rufus-ruby] :

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
Justin Reagor, http://blog.kineticweb.com/


== the rest of Rufus

http://rufus.rubyforge.org


== license

MIT

