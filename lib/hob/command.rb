require 'open3'

module Hob
  class Command
    attr_reader :status

    attr_reader :success_log

    attr_reader :fail_log

    def initialize(command, dir)
      @command = command

      @options = {
        chdir: dir
      }

      run_command
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
  end
end
