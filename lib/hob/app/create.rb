module Hob
  class App
    class Create

      attr_reader :app

      def call
        create_filesystem
        clone_repo if app.repo
        persist
      end

    private

      def initialize(app)
        @app = app
      end

      def create_filesystem
        paths = app.paths

        FileUtils.mkdir_p(paths.root)
        FileUtils.mkdir_p(paths.repo)
        FileUtils.mkdir_p(paths.shared)
        FileUtils.mkdir_p(paths.releases)
      end

      def clone_repo
        Command.new("git clone #{app.repo} #{app.paths.repo}").log
      end

      def persist
        app.persist!
      end
    end
  end
end
