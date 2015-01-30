module Hob
  class App
    class Deploy

      CommandFailed = Class.new(StandardError)

      attr_reader :app

      attr_reader :result

      attr_reader :logs

      def start
        Dir.chdir(app.paths.current) do
          with_env do
            app.start_commands.each_line do |command|
              log(Command.new(command))
            end
          end
        end
      end

      def stop
        Dir.chdir(app.paths.current) do
          with_env do
            app.stop_commands.each_line do |command|
              log(Command.new(command))
            end
          end
        end
      end

      def call
        @deploy_id = World.db[:deploys].insert(app_name: app.name.to_s, started_at: Time.now)
        @success   = true
        @logs      = []
        @result    = {}
        time_start = Time.now

        begin
          checkout
          prepare
          stop
          link_current
          start
        rescue => e
          FileUtils.rm_rf(app.paths.release(@revision)) if @revision
          # TODO log error if not CommandFailed
          # TODO link and start old rev
        ensure
          time_finish = Time.now

          World.db[:deploys].where(id: @deploy_id).update({
            revision:     @revision,
            is_success:   @success,
            elapsed_time: time_finish - time_start,
            finished_at:  time_finish
          })

          @result = World.db[:deploys][id: @deploy_id]
        end
      end

    private

      def initialize(app)
        @app = app
      end

      def checkout
        Dir.chdir(app.paths.repo) do
          log(Command.new('git fetch origin'))

          @revision = %x(git rev-list --max-count=1 --abbrev-commit origin/#{app.branch}).strip

          log(Command.new("git reset --hard #{@revision}"))
        end
      end

      def prepare
        rev_path = app.paths.release(@revision)

        FileUtils.rm_rf(rev_path)
        FileUtils.cp_r(app.paths.repo, rev_path)
        Dir.chdir(rev_path) do
          with_env do
            app.prepare_commands.each_line do |command|
              log(Command.new(command))
            end
          end
        end
      end

      def link_current
        FileUtils.rm_rf(app.paths.current)
        FileUtils.ln_s(app.paths.release(@revision), app.paths.current)
      end

      def log(entry)
        params = {
          deploy_id: @deploy_id,
          command:   entry.command,
          status:    entry.status,
          elapsed_time: entry.elapsed_time,
          log:          entry.log
        }

        @logs << params
        World.db[:deploy_logs].insert(params)

        if entry.status != 0
          @success = false
          fail CommandFailed
        end
      end

      def with_env
        Lang::Ruby.new.within(app.ruby_version) do
          app.env.within do
            app.prepare_commands.each_line do |command|
              yield
            end
          end
        end
      end

    end
  end
end
