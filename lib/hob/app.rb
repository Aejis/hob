module Hob
  ##
  # Class: Application settings
  #
  class App
    APPS_DIR = 'apps'.freeze

    REG_NAME = /^[A-z_-]+$/.freeze

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

    ##
    # Repo is on github
    #
    def github?
      @repo.include?('github.com')
    end

    ##
    # Return prettified github repo name
    #
    def github
      @github ||= begin
        uri = Addressable::URI.parse(@repo)
        uri.path.gsub(/\.git$/, '')
      end
    end

    ##
    # Save app data to database
    #
    def persist!
      return false unless valid?

      if persisted?
        World.db[:apps].where(name: name).update(@diff) unless @diff.empty?
        @name = @params[:name]
      else
        World.db[:apps].insert(@params)
        @persisted = true
      end
    end

    ##
    # Returns: false if app data was not stored in database
    #
    def persisted?
      @persisted
    end

    ##
    # Returns: true if app's name was changed
    #
    def name_changed?
      @diff.has_key?(:name)
    end

    def errors
      errors = {}
      errors[:name] = 'Must contain only latin letters, dashes or underscores' unless REG_NAME.match(@params[:name])
      errors
    end

    ##
    # Returns: true if application properties are valid
    #
    def valid?
      !errors.any?
    end

  private

    ALLOWED_FIELDS = Set[:name, :repo, :branch, :ruby_version, :prepare_commands, :test_commands, :start_commands, :stop_commands].freeze

    ##
    # Constructor
    #
    # Params:
    # - name {String|Symbol} application name
    #
    def initialize(name, data={})
      @persisted = false

      @name   = name
      @paths  = Paths.new(Hob::World.root_path.join(APPS_DIR, name))
      @env    = Env.new(self)

      data    = restrict(data)
      from_db = retrieve
      @params = from_db.merge(data)
      @diff   = data.inject({}) do |diff, (k, v)|
        diff[k] = v if from_db[k] != v
        diff
      end

      @repo         = @params[:repo]
      @branch       = @params[:branch]
      @ruby_version = @params[:ruby_version]
      @start_commands = @params[:start_commands]
      @stop_commands  = @params[:stop_commands]
      @test_commands  = @params[:test_commands]
      @prepare_commands = @params[:prepare_commands]
    end

    def retrieve
      if data = World.db[:apps][name: @name]
        @persisted = true
        data
      else
        {}
      end
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
