
require 'rubygems'

require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'tasks/dev'

begin
  require 'hanna/rdoctask'
rescue LoadError => e
  require 'rake/rdoctask'
end

gemspec = File.read('rufus-tokyo.gemspec')
eval "gemspec = #{gemspec}"

#
# tasks

CLEAN.include('pkg', 'tmp', 'html')

task :default => [ :clean, :repackage ]


#
# SPECING

task :spec do
  load File.dirname(__FILE__) + '/spec/spec.rb'
end


#
# TESTING
#Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib'
#  t.libs << 'test'
#  t.test_files = FileList['test/test.rb']
#  t.verbose = true
#end
task :test => :spec


#
# VERSION

task :change_version do

  version = ARGV.pop
  `sedip "s/VERSION = '.*'/VERSION = '#{version}'/" lib/rufus/tokyo.rb`
  `sedip "s/s.version = '.*'/s.version = '#{version}'/" rufus-tokyo.gemspec`
  exit 0 # prevent rake from triggering other tasks
end


#
# PACKAGING

Rake::GemPackageTask.new(gemspec) do |pkg|
  #pkg.need_tar = true
end

Rake::PackageTask.new('rufus-tokyo', gemspec.version) do |pkg|

  pkg.need_zip = true

  pkg.package_files = FileList[
    'Rakefile',
    '*.txt',
    'lib/**/*',
    'spec/**/*',
    'test/**/*'
  ].to_a
  pkg.package_files.delete('lib/tokyotyrant.rb')

  class << pkg
    def package_name
      "#{@name}-#{@version}-src"
    end
  end
end


#
# DOCUMENTATION

task :rdoc do
  sh %{
    rm -fR html/rufus-tokyo
    yardoc 'lib/**/*.rb' \
      -o html/rufus-tokyo \
      --title 'rufus-tokyo'
  }
end


#
# WEBSITE

task :upload_website => [ :clean, :rdoc ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/rufus'

  sh "rsync -azv -e ssh html/rufus-tokyo #{account}:#{webdir}/"
end

