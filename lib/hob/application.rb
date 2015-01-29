module Hob
  module Hob
    ##
    # Class: Application settings
    #
    class Application

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
      # Returns: {Hob::Application::Paths}
      #
      attr_reader :paths

      ##
      # Get list of builds
      #
      def builds
        Hob::World.db[:builds].where(app_name: name)
      end

    private

      ##
      # Constructor
      #
      # Params:
      # - name {String|Symbol} application name
      #
      def initialize(name)
        @name   = name.to_sym
        @paths  = Paths.new(Hob::World.root_path.join(APPS_DIR, name))
        @params = World.db[:apps][name: name]
      end

    end
  end
end
