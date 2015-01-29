require 'open3'

module Hob
  class Command
    attr_reader :status

    attr_reader :success_log

    attr_reader :fail_log

    def initialize(command, dir, params)
      @command = command

      @options = {
        chdir: dir
      }

      run_in_env(params[:rubies_path], params[:version], params[:exports]) do
        run_command
      end
    end

    def run_command
      begin
        Open3.popen3(@command, @options) do |_, stdout, stderr, wait_thr|
          @status      = wait_thr.value.exitstatus
          @success_log = stdout.read
          @fail_log    = stderr.read
        end
      rescue Errno::ENOENT => e
        @fail_log = e.message
      end
    end

    private

    def run_in_env(rubies_path, version, exports)
      exports ||= {}
      old_path = ENV["PATH"]

      ruby_root = File.join(rubies_path, "ruby-#{version}/bin") if version
      ruby_root ||= `which ruby`

      ENV["PATH"] = ruby_root + ':' + ENV["PATH"]
      exports.each { |k, v| ENV[k] = v }

      yield

      ENV["PATH"] = old_path
      exports.each { |k, _| ENV[k] = nil }
    end
  end
end
