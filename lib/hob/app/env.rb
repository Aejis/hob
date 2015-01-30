module Hob
  class App
    class Env
      attr_reader :app_name

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
          World.db[:app_envs].insert(app_name: app_name, key: key.upcase, value: val)
        end
      end

      def update(oldkey, newkey, value)
        World.db[:app_envs].where(app_name: app_name, key: oldkey).update(key: newkey, value: value)
      end

      def delete(key)
        World.db[:app_envs].where(app_name: app_name, key: key).delete
      end

      ##
      # Iterate over env variables
      #
      def each(&block)
        return enum_for(:each) unless block_given?
        all.each do |env|
          block.call(env[:key], env[:value])
        end
      end

      def within
        keys = []
        each do |k, v|
          keys << k
          ENV[k] = v
        end

        yield

        keys.each { |k| ENV.delete(k) }
      end

      ##
      # Get all env variables
      #
      def all
        World.db[:app_envs].where(app_name: app_name)
      end

    private

      def initialize(app_name)
        @app_name = app_name
      end

      def get(key)
        World.db[:app_envs][app_name: app_name, key: key.upcase]
      end
    end
  end
end
