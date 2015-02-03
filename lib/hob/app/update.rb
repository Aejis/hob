module Hob
  class App
    class Update

      attr_reader :app

      def call
        persist
        rename_dir
      end

    private

      def initialize(app)
        @app = app
      end

      def persist
        app.persist!
      end

      def rename_dir
        if app.name_changed?
          FileUtils.mv(app.paths.root, World.root_path.join(APPS_DIR, app.name))
        end
      end
    end
  end
end
