require 'pathname'

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
        raise 'world was not setted up' unless @instance
        @instance.send(method, *args, &block)
      end
    end

    private_class_method :new

    attr_reader :root_path

    attr_reader :db_uri

    attr_reader :port

    attr_reader :server

    attr_reader :pid

    def db
      self.class.mutex.synchronize do
        @db ||= Sequel.connect(options[:db_uri])
      end
    end

  private

    def initialize(options)
      @root_path = Pathname.new(options[:root_path])
      @port   = options[:port]
      @pid    = options[:pid_file]
      @server = options[:server]
    end
  end
end
