require 'hob/migrator'

module Hob
  class Tasks
    class << self
      def start
        puts "Start hob-server on port #{ World.port }"
        # Process.daemon(true)

        Rack::Server.start({ :app => Web, :Port => World.port, :server => World.server, :pid => World.pid })
      end

      def stop
        pid = %x{cat #{ World.pid }}.to_i
        puts "Stop hob-server with pid #{ pid }"
        Process.kill(15, pid)
        puts 'done'
        exit
      end

      def migrate
        Migrator.migrate
        exit
      end
    end
  end
end
