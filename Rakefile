
require 'rubygems'

require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'tasks/dev'

#require 'rake/rdoctask'
require 'hanna/rdoctask'

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
  #pkg.package_files.delete("MISC.txt")
  class << pkg
    def package_name
      "#{@name}-#{@version}-src"
    end
  end
end


#
# DOCUMENTATION

Rake::RDocTask.new do |rd|

  rd.main = 'README.txt'
  rd.rdoc_dir = 'html/rufus-tokyo'
  rd.rdoc_files.include(
    'README.txt',
    'CHANGELOG.txt',
    'LICENSE.txt',
    'CREDITS.txt',
    'lib/**/*.rb')
  rd.rdoc_files.exclude('lib/tokyotyrant.rb')
  rd.title = 'rufus-tokyo rdoc'
  rd.options << '-N' # line numbers
  rd.options << '-S' # inline source
end

task :rrdoc => :rdoc do
  FileUtils.cp('doc/rdoc-style.css', 'html/rufus-tokyo/')
end


#
# WEBSITE

task :upload_website => [ :clean, :rrdoc ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/rufus'

  sh "rsync -azv -e ssh html/rufus-tokyo #{account}:#{webdir}/"
end

