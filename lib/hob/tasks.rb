module Hob
  class Tasks
    class << self
      def start
        puts "Start hob-server on port #{ World.port }"
        Process.daemon(true)

        Rack::Server.start({ :app => Web, :Port => World.port, :server => World.server, :pid => World.pid })
      end

      def stop
        pid = %x{cat #{ World.pid }}.to_i
        puts "Stop hob-server with pid #{ pid }"
        Process.kill(15, %x{cat #{ World.pid }}.to_i)
        puts 'done'
        exit
      end

      def migrate
        p 'perform migrations'
        # start migration here
        exit
      end
    end
  end
end
