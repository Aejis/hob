require 'pathname'

require 'sequel'

module Hob
  class World
    @mutex = Mutex.new

    class << self
      attr_reader :mutex

      def setup(options)
        mutex.synchronize do
          @instance ||= new(options)
        end
      end

      def method_missing(method, *args, &block)
        raise 'world was not set up' unless @instance
        @instance.send(method, *args, &block)
      end
    end

    private_class_method :new

    attr_reader :root_path

    attr_reader :db_uri

    attr_reader :port

    attr_reader :server

    attr_reader :pid

    attr_reader :github_options

    attr_reader :hostname

    def db
      self.class.mutex.synchronize do
        @db ||= Sequel.connect(@db_uri)
      end
    end

  private

    def initialize(options)
      @root_path = Pathname.new(options[:root_path])
      @port      = options[:port]
      @pid       = options[:pid_file]
      @server    = options[:server]
      @db_uri    = options[:db_uri]
      @hostname  = options[:hostname]
      # @github_options = {
      #   client_id: options[:github][:client_id],
      #   secret: options[:github][:secret]
      # }
    end
  end
end
