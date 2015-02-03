module Hob
  ##
  # Class: Application settings
  #
  class App

    APPS_DIR = 'apps'.freeze

    ##
    # Application name
    #
    # Returns: {Symbol}
    #
    attr_reader :name

    ##
    # Application paths
    #
    # Returns: {Hob::App::Paths}
    #
    attr_reader :paths

    ##
    # Application env variables
    #
    # Returns: {Hob::App::Env}
    attr_reader :env

    ##
    # Git repository
    #
    attr_reader :repo

    ##
    # Git branch
    #
    attr_reader :branch

    ##
    # Ruby version
    #
    attr_reader :ruby_version

    ##
    # Commands required to prepare application for deploy
    #
    attr_reader :prepare_commands

    ##
    # Commands needed to test application
    #
    attr_reader :test_commands

    ##
    # Commands required to run application
    #
    attr_reader :start_commands

    ##
    # Commands required to stop application
    #
    attr_reader :stop_commands

    ##
    # Application params hash
    #
    attr_reader :params

    ##
    # Serialize for JSON
    #
    def to_json(*)
      JSON.dump(params)
    end

    ##
    # Get list of builds
    #
    def builds
      Hob::World.db[:builds].where(app_name: name)
    end

  private

    ALLOWED_FIELDS = Set[:name, :repo, :branch, :ruby_version, :prepare_commands, :test_commands, :start_commands, :stop_commands].freeze

    ##
    # Constructor
    #
    # Params:
    # - name {String|Symbol} application name
    #
    def initialize(name, params=nil)
      @name   = name.to_sym
      @paths  = Paths.new(Hob::World.root_path.join(APPS_DIR, name))
      @env    = Env.new(self)
      @params = restrict(params || World.db[:apps][name: name] || {})

      @repo         = @params[:repo]
      @branch       = @params[:branch]
      @ruby_version = @params[:ruby_version]
      @start_commands = @params[:start_commands]
      @stop_commands  = @params[:stop_commands]
      @test_commands  = @params[:test_commands]
      @prepare_commands = @params[:prepare_commands]
    end

    def restrict(params)
      symbolize(params).keep_if { |k, _| ALLOWED_FIELDS.include?(k) }
    end

    def symbolize(params)
      params.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = value
      end
    end

  end

end
