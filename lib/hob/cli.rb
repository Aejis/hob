require 'pathname'

module Hob
  class CLI < Thor
    class_option :root, type: :string, aliases: '-r', banner: 'Deploy root'

    map '-v' => :version

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

    desc 'migrate', 'Migrate hob database'
    def migrate
      require 'hob/world'
      require 'hob/migrator'

      Hob::World.setup(make_opts)
      Hob::Migrator.migrate
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
        pid_file:  pid_file
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
      config[:pid_file] || root_path.join('hob.pid')
    end

    def port
      config[:port] || 8081
    end

    def server
      config[:server] || :webrick
    end
  end
end
