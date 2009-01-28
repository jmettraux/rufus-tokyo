
= rufus-tokyo

ruby-ffi based interface to Tokyo Cabinet.

The 'abstract' and the 'table' API are covered for now.


== installation

  sudo gem install ffi rufus-tokyo

  (see after 'usage' for how to install Tokyo Cabinet if required)


== usage

=== Abstract API

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


=== Table API

http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

  require 'rubygems'
  require 'rufus/tokyo/cabinet/table'
  
  t = Rufus::Tokyo::Table.new('table.tdb', :create, :write)
  
  t['pk0'] = { 'name' => 'alfred', 'age' => '22' }
  t['pk1'] = { 'name' => 'bob', 'age' => '18' }
  t['pk2'] = { 'name' => 'charly', 'age' => '45' }
  t['pk3'] = { 'name' => 'doug', 'age' => '77' }
  t['pk4'] = { 'name' => 'ephrem', 'age' => '32' }
  
  p t.query { |q|
    q.add_condition 'age', :eq, '32'
  }
  
  t.close


more in the rdoc

  http://rufus.rubyforge.org/rufus-tokyo/
  http://rufus.rubyforge.org/rufus-tokyo/classes/Rufus/Tokyo/Cabinet.html
  http://rufus.rubyforge.org/rufus-tokyo/classes/Rufus/Tokyo/Table.html

or directly in the source

  http://github.com/jmettraux/rufus-tokyo/blob/master/lib/rufus/tokyo/cabinet/abstract.rb
  http://github.com/jmettraux/rufus-tokyo/blob/master/lib/rufus/tokyo/cabinet/table.rb


== Tokyo Cabinet install

On a Mac, you would do 

  sudo port install tokyocabinet


If you don't have Tokyo Cabinet on your system, you can get it and compile it :

  git clone git://github.com/etrepum/tokyo-cabinet.git
  cd tokyo-cabinet
  git checkout 1.4.2
  ./configure
  make
  sudo make install


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


== author

John Mettraux, jmettraux@gmail.com
http://jmettraux.wordpress.com


== the rest of Rufus

http://rufus.rubyforge.org


== license

MIT

