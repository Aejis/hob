require 'open3'

module Hob
  class Command
    attr_reader :command

    attr_reader :status

    attr_reader :success_log

    attr_reader :fail_log

    attr_reader :elapsed_time

    def log
      [success_log, fail_log].join("\n")
    end

    def run_command
      begin
        start_time = Time.now
        Open3.popen3(@command.strip, @options) do |_, stdout, stderr, wait_thr|
          @status      = wait_thr.value.exitstatus
          @success_log = stdout.read
          @fail_log    = stderr.read
        end
      rescue Errno::ENOENT => e # Command not found
        @status = 127
        @fail_log = e.message
      ensure
        @elapsed_time = Time.now - start_time
      end
    end

  private

    def initialize(command, dir=nil)
      @command = command
      @options = {}
      @options[:chdir] = dir.to_s if dir

      run_command
    end

  end
end
