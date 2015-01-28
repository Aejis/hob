require 'pathname'

module Hob
  class World
    @mutex = Mutex.new

    class << self
      def setup(options)
        @mutex.synchronize do
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

    attr_reader :db

    attr_reader :port

    attr_reader :server

    attr_reader :pid

  private

    def initialize(options)
      @root_path = Pathname.new(options[:root_path])
      @db = Sequel.connect(options[:db])
      @port   = options[:port]
      @pid    = options[:pid_file]
      @server = options[:server]
    end
  end
end
