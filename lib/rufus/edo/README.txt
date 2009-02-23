
= Rufus::Edo

wrapping Hirabayashi-san's 'native' ruby bindings into a rubiyst-friendly set of Ruby classes.

In order to use Rufus::Edo, you have to have the libtokyocabinet dynamic library installed on your system :

  http://openwferu.rubyforge.org/tokyo.html

Then you can install the 'native' C bindings.

NOTE : I have only tested those native bindings with Ruby 1.8.6. To run them with JRuby, the best option is Rufus::Tokyo and its FFI bindings.

NOTE : the Ruby tyrant library provided by Hirabayashi-san is not a C binding, it's a pure Ruby connector. It is slower than Rufus::Tokyo::Tyrant and Rufus::Tokyo::TyrantTable, but the advantage is that there is no need to install cabinet and tyrant C libraries to connect your Ruby code to your Tokyo Tyrant.


== installation of the 'native' C bindings

=== Careo's mirror gem

  sudo gem install careo-tokyocabinet


=== directly from http://sf.net/tokyocabinet

Get the tokyocabinet-ruby package at :

  http://sourceforge.net/project/showfiles.php?group_id=200242

unpack it :

  tar xzvf tokyocabinet-ruby-1.20.tar.gz
  cd tokyocabinet-ruby-1.20

and then, as described at : http://tokyocabinet.sourceforge.net/rubydoc/

  ruby extconf.rb
  make
  sudo make install


== Rufus::Edo::Cabinet

  require 'rufus/edo' # sudo gem install rufus-tokyo

  db = Rufus::Edo::Cabinet.new('data.tch')

  db['a'] = 'alpha'

  # ...

  db.close


== Rufus::Edo::Table

  require 'rufus/edo'

  db = Rufus::Edo::Table.new('data.tct')

  db['customer1'] = { 'name' => 'Taira no Kyomori', 'age' => '55' }

  # ...

  db.close


== Rufus::Edo::Tyrant

coming soon.


== Rufus::Edo::TyrantTable

coming soon.

