require 'pathname'

module Hob
  class CLI < Thor
    include Thor::Actions

    class_option :root, type: :string, aliases: '-r', banner: 'Deploy root'

    map '-v' => :version

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    desc 'start', 'Start hob-server'
    def start
      require 'hob'
      Hob::World.setup(make_opts)

      puts "Start hob-server on port #{ Hob::World.port }"

      # Process.daemon(true)
      Rack::Server.start({ :app => Hob::Web, :Port => Hob::World.port, :server => Hob::World.server, :pid => Hob::World.pid })
    end

    desc 'stop', 'Stop hob-server'
    def stop
      require 'hob'
      Hob::World.setup(make_opts)

      pid = %x{cat #{ World.pid }}.to_i
      puts "Stop hob-server with pid #{ pid }"

      Process.kill(15, pid)

      puts 'done'
    end

    desc 'bootstrap', 'Generate hob application directory'
    def bootstrap
      empty_directory(root_path)
      empty_directory(root_path.join('apps'))
      empty_directory(root_path.join('rubies'))

      template('hob.yml', root_path.join('hob.yml'))

      migrate
      add_admin

      puts
      puts
      puts <<-BANNER
      You are about to finish

      Now, edit your #{root_path.join('hob.yml').to_s}

      If you decide to use another DB, change 'db_url' section and then:
        Remove #{root_path.join('hob.sqlite').to_s}
        Run: $ hob-server migrate
        Run: $ hob-server add_admin

      You may also want to install some ruby:
        via ruby-install: $ ruby-install --rubies-dir #{root_path.join('rubies').to_s} ruby 2.2.0
        via ruby-build:   $ ruby-build 2.2.0 #{root_path.join('rubies', 'ruby-2.2.0').to_s}

        or manually to #{root_path.join('rubies').to_s}

      Then, start server with:
        $ hob-server start

      Go to http://localhost:#{options[:port]}/, login with user "#{@login}" and start setting up your apps
      BANNER
    end

    desc 'migrate', 'Migrate hob database'
    def migrate
      require 'hob/world'
      require 'hob/migrator'

      Hob::World.setup(make_opts)
      Hob::Migrator.migrate
    end

    desc 'add_admin', 'Add admin user'
    def add_admin
      require 'hob/world'
      require 'hob/user'

      Hob::World.setup(make_opts)

      @login = ask('User name')
      pass  = ask('User password', :echo => false)

      user = Hob::User.new(login: @login, password: pass)
      user.admin!
      user.approve!
      user.persist!
    end

    desc 'version', 'Show version'
    def version
      puts Hob::VERSION::String
    end

  private

    def make_opts
      {
        root_path: root_path,
        port:      port,
        db_uri:    db_uri,
        server:    server,
        pid_file:  pid_file,
        hostname:  hostname,
        github:    config[:github]
      }
    end

    def root_path
      @root_path ||= Pathname.new(options[:root] || Dir.pwd)
    end

    def config
      @config ||= YAML.load_file(root_path.join('hob.yml')) rescue {}
    end

    def db_uri
      @db_uri ||= config[:db_uri] || "sqlite://#{root_path.join('hob.sqlite')}"
    end

    def pid_file
      config['pid_file'] || root_path.join('hob.pid')
    end

    def port
      config['port'] || 8081
    end

    def server
      (config['server'] || :webrick).to_sym
    end

    def hostname
      config['hostname'] || `hostname`.strip
    end
  end
end
