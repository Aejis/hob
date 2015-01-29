module Hob
  class App

    ##
    # Class: application paths
    #
    class Paths

      ##
      # Application root folder
      #
      # Returns: {Pathname}
      #
      attr_reader :root

      ##
      # SCM folder
      #
      # Returns: {Pathname}
      #
      attr_reader :repo

      ##
      # Shared data folder
      #
      # Returns: {Pathname}
      #
      attr_reader :shared

      ##
      # Releases folder
      #
      # Returns: {Pathname}
      #
      attr_reader :releases

      ##
      # Symlink to current release
      #
      # Returns: {Pathname}
      #
      attr_reader :current

      ##
      # Real current release folder
      #
      # Returns: {Pathname}
      #
      def current_release
        releases.join(current_release_num.to_s)
      end

      ##
      # Next release folder
      #
      # Returns: {Pathname}
      #
      def next_release
        releases.join((current_release_num + 1).to_s)
      end

      ##
      # Previous release folder
      #
      # Returns: {Pathname}
      #
      def prev_release
        releases.join(num.to_s)
      end

    private

      ##
      # Constructor
      #
      # Params:
      # - root_path {Pathname} path to **application** root directory
      #
      def initialize(root_path)
        @root     = root_path
        @repo     = root_path.join('repo')
        @shared   = root_path.join('shared')
        @releases = root_path.join('releases')
        @current  = root_path.join('current')

        freeze
      end

      ##
      # Private: last release number
      #
      # Returns: {Integer}
      #
      def current_release_num

      end

    end

  end
end
