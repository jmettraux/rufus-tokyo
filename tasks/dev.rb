  desc "tasks for handling extension libraries"
  namespace :ext do

    def git_repo
      {
        :cabinet => "git://github.com/etrepum/tokyo-cabinet.git",
        :tyrant => "git://github.com/etrepum/tokyo-tyrant.git"
      }
    end

    def extensions
      [:cabinet, :tyrant]
    end

    def ext_root_path
      File.expand_path(File.join(File.dirname(__FILE__), '..', 'ext'))
    end

    def ext_local_of type
      File.join(ext_root_path, "tokyo-#{type}")
    end

    desc "creates the extensions build directory"
    task :create do
      mkdir_p ext_root_path
    end

    desc "removes the extensions build directory"
    task :remove do
      rm_rf ext_root_path
    end

    desc "builds the extensions, takes PREFIX for where to install"
    task :build => [:create] do
      extensions.each do |ext|
        sh "cd #{ext_local_of ext} &&
            ./configure --prefix=#{ENV['PREFIX'] || '/usr/local'} && 
            make"
      end
    end

    desc "installs the extensions [REQUIRES SUDO AND BUILD_ALL]"
    task :install do
      extensions.each do |ext|
        sh "cd #{ext_local_of ext} && sudo make install"
      end
    end

    desc "clones/pulls and builds all extensions, takes PREFIX for where to install"
    task :build_all => [:create] + extensions + [:build]

    desc "builds and installs all the extensions"
    task :install_all => [:build_all, :install]

    desc "update all the extensions"
    task :update_all => extensions

    extensions.each do |ext|
      desc "clones and/or updates the etrepum/tokyo-#{ext} repo"
      task ext => [:create] do
        repo = ext_local_of ext
        if ! File.directory?(repo)
          sh "cd #{ext_root_path} && git clone #{git_repo[ext]}"
        else
          sh "cd #{repo} && git checkout master && git pull"
        end
      end
    end

  end
