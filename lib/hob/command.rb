require 'open3'

module Hob
  class Command
    attr_reader :status

    attr_reader :success_log

    attr_reader :fail_log

    def log
      [success_log, fail_log].join("\n")
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

    def initialize(command, dir=nil)
      @command = command
      @options = {}
      @options[chdir] = dir if dir

      run_command
    end

  end
end
