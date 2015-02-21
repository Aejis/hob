module Hob
  class App
    class Action

      CommandFailed = Class.new(StandardError)

      attr_reader :id

      attr_reader :app

      attr_reader :result

      def start
        perform('start') do
          _start
        end
      end

      def stop
        perform('stop') do
          _stop
        end
      end

      def deploy
        perform('deploy', true) do
          checkout
          prepare
          _run_tests
          _stop
          link_current
          link_shared
          _start
        end
      end

      def logs
        World.db[:action_logs].where(action_id: @id)
      end

    private

      def initialize(app, user)
        @app = app
        @user = user
      end

      def checkout
        return unless app.repo

        Dir.chdir(app.paths.repo) do
          log(Command.new('git fetch origin'))

          @revision = %x(git rev-list --max-count=1 origin/#{app.branch}).strip

          log(Command.new("git reset --hard #{@revision}"))
        end
      end

      def prepare
        rev_path = app.paths.release(@number)

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
        FileUtils.ln_s(app.paths.release(@number), app.paths.current)
      end

      def link_shared
        files_for_linkage(app.paths.shared).flatten.each do |file|
          target = app.paths.current.join(file)
          FileUtils.rm(target) if File.exists?(target)
          FileUtils.ln_s(app.paths.shared.join(file), target)
        end
      end

      def log(entry)
        params = {
          action_id: @id,
          command:   entry.command,
          status:    entry.status,
          elapsed_time: entry.elapsed_time,
          log:          entry.log
        }

        World.db[:action_logs].insert(params)

        fail CommandFailed if entry.status != 0
      end

      def perform(type, new_release=false)
        @success   = true
        @result    = {}

        @time_start = Time.now
        @number     = @time_start.strftime('%Y%m%d%H%M%S') # FIXME: Get release number unless new_release

        data = { app_name: app.name.to_s, type: type, number: @number, requested_by: @user.login, started_at: @time_start }

        unless new_release
          Dir.chdir(app.paths.current) do
            data[:revision] = @revision = %x(git rev-list --max-count=1 origin/#{app.branch}).strip
          end
        end

        @id = World.db[:actions].insert(data)

        begin
          Bundler.with_clean_env do
            yield
          end
        rescue => e
          @success = false

          # FileUtils.rm_rf(app.paths.release(@number))
          # TODO log error if not CommandFailed
          # TODO link and start old rev
        ensure
          time_finish = Time.now

          World.db[:actions].where(id: @id).update({
            revision:     @revision,
            is_success:   @success,
            elapsed_time: time_finish - @time_start,
            finished_at:  time_finish
          })

          @result = World.db[:actions][id: @id]
        end
      end

      def with_env
        Lang::Ruby.new.within(app.ruby_version) do
          app.env.within do
            yield
          end
        end
      end

      def _start
        return false unless File.exists?(app.paths.current)
        Dir.chdir(app.paths.current) do
          with_env do
            app.start_commands.each_line do |command|
              log(Command.new(command))
            end
          end
        end
      end

      def _stop
        return false unless File.exists?(app.paths.current)
        Dir.chdir(app.paths.current) do
          with_env do
            app.stop_commands.each_line do |command|
              log(Command.new(command))
            end
          end
        end
      end

      def _run_tests
        return false unless File.exists?(app.paths.current)
        Dir.chdir(app.paths.current) do
          with_env do
            app.test_commands.each_line do |command|
              log(Command.new(command))
            end
          end
        end
      end

      def files_for_linkage(dir)
        Dir[dir.join('*')].map do |file|
          rel    = Pathname.new(file).relative_path_from(app.paths.shared)
          target = app.paths.current.join(rel)

          if File.exists?(target) && File.directory?(target)
            files_for_linkage(app.paths.shared.join(rel))
          else
            rel
          end
        end
      end

    end
  end
end
