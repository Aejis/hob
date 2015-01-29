module Hob
  class App
    class Create

      attr_reader :app

      def call
        create_filesystem
        clone_repo
        persist
      end

    private

      def initialize(app)
        @app = app
      end

      def create_filesystem
        paths = app.paths

        FileUtils.mkdir(paths.root)
        FileUtils.mkdir(paths.repo)
        FileUtils.mkdir(paths.shared)
        FileUtils.mkdir(paths.releases)
      end

      def clone_repo
        Command.new("git clone #{app.repo} #{app.paths.repo}").log
      end

      def persist
        World.db[:apps].insert(app.params)
      end
    end
  end
end
