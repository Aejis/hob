module Hob
  class App
    class Env
      attr_reader :app

      ##
      # Get env variable
      #
      def [](key)
        get(key.upcase)[:value]
      end

      ##
      # Add env variable
      #
      def []=(key, val)
        key = key.upcase
        if record = get(key)
          record.update(value: val)
        else
          db.insert(app_name: @app_name, key: key.upcase, value: val)
        end
      end

      def update(oldkey, newkey, value)
        db.where(app_name: @app_name, key: oldkey).update(key: newkey, value: value)
      end

      def delete(key)
        db.where(app_name: @app_name, key: key).delete
      end

      ##
      # Iterate over env variables
      #
      def each(&block)
        return enum_for(:each) unless block_given?
        predefined.concat(user).each do |env|
          block.call(env[:key], env[:value])
        end
      end

      def within
        keys = []
        each do |k, v|
          keys << k
          ENV[k] = v
        end

        begin
          yield
        ensure
          keys.each { |k| ENV.delete(k) }
        end
      end

      def predefined
        [
          { key: 'APP_ROOT_DIR',    value: app.paths.root.to_s },
          { key: 'APP_CURRENT_DIR', value: app.paths.current.to_s }
        ]
      end

      def to_json
        {
          app_name: @app_name,
          predefined: predefined,
          user: user
        }
      end

      ##
      # Get user defined env variables
      #
      def user
        db.where(app_name: @app_name).all
      end

    private

      def initialize(app)
        @app = app
        @app_name = app.name.to_s
      end

      def db
        World.db[:app_envs]
      end

      def get(key)
        db[app_name: @app_name, key: key.upcase]
      end

    end
  end
end
