module Hob
  class Tasks
    class << self
      def start
        p 'run start'
        # daemonize read this https://github.com/rack/rack/blob/master/lib/rack/server.rb#L166
        # not work
        Rack::Server.start({ :app => Hob::Web, :Port => World.port, :server => World.server, :pid => World.pid })
      end

      def stop
        p 'run stop'
        # stop code here
      end

      def migrate
        p 'perform migrations'
        # start migration here
      end
    end
  end
end