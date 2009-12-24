

require 'lib/rufus/tokyo/version.rb'

require 'rubygems'
require 'rake'


#
# CLEAN

require 'rake/clean'
CLEAN.include('pkg', 'tmp', 'html')
task :default => [ :clean ]


#
# GEM

require 'jeweler'

Jeweler::Tasks.new do |gem|

  gem.version = Rufus::Tokyo::VERSION
  gem.name = 'rufus-tokyo'

  gem.summary =
    'ruby-ffi based lib to access Tokyo Cabinet, Tyrant and Dystopia'
  gem.description = %{
Ruby-ffi based lib to access Tokyo Cabinet and Tyrant.

The ffi-based structures are available via the Rufus::Tokyo namespace.
There is a Rufus::Edo namespace that interfaces with Hirabayashi-san's native Ruby interface, and whose API is equal to the Rufus::Tokyo one.

Finally rufus-tokyo includes ffi-based interfaces to Tokyo Dystopia (thanks to Jeremy Hinegardner).
  }

  gem.email = 'jmettraux@gmail.com'
  gem.homepage = 'http://github.com/jmettraux/rufus-tokyo/'

  gem.authors = [
    'John Mettraux', 'Zev Blut', 'Jeremy Hinegardner', 'James Edward Gray II' ]

  gem.rubyforge_project = 'rufus'

  gem.test_file = 'spec/spec.rb'

  gem.add_dependency 'ffi'
  gem.add_development_dependency 'yard', '>= 0'

  #gem.files = Dir['lib/**/*.rb'] + Dir['*.txt'] - [ 'lib/tokyotyrant.rb' ]
  #gem.files.reject! { |fn| fn == 'lib/tokyotyrant.rb' }

  # gemspec spec : http://www.rubygems.org/read/chapter/20
end
Jeweler::GemcutterTasks.new


#
# DOC

begin

  require 'yard'

  YARD::Rake::YardocTask.new do |doc|
    doc.options = [
      '-o', 'html/rufus-tokyo', '--title',
      "rufus-tokyo #{Rufus::Tokyo::VERSION}"
    ]
  end

rescue LoadError

  task :yard do
    abort "YARD is not available : sudo gem install yard"
  end
end


#
# TO THE WEB

task :upload_website => [ :clean, :yard ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/rufus'

  sh "rsync -azv -e ssh html/rufus-tokyo #{account}:#{webdir}/"
end

