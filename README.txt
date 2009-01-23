
= rufus-tokyo

ruby-ffi based interface to Tokyo Cabinet


== installation

  sudo gem install ffi rufus-tokyo

  (see after 'usage' for how to install Tokyo Cabinet if required)


== usage

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


== Tokyo Cabinet install

On a Mac, you would do 

  sudo port install tokyocabinet


If you don't have Tokyo Cabinet on your system, you can get it and compile it :

  git clone git://github.com/etrepum/tokyo-cabinet.git
  cd tokyo-cabinet
  git checkout 1.4.1
  ./configure
  make

eventually

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

many thanks to the authors of Tokyo Cabinet (http://tokyocabinet.sourceforge.net)

and to the authors of ruby-ffi (http://kenai.com/projects/ruby-ffi)


== author

John Mettraux, jmettraux@gmail.com
http://jmettraux.wordpress.com


== the rest of Rufus

http://rufus.rubyforge.org


== license

MIT

