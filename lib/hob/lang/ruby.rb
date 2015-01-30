module Hob
  module Lang
    class Ruby

      attr_reader :path

      def versions
        Dir.glob(path.join('*')).select { |entry| File.directory?(entry) }.map { |dir| File.basename(dir) }
      end

      def within(version=nil)
        if version
          old_path = ENV['PATH']

          ruby_root = File.join(path.join(version).to_s, 'bin')
          ENV['PATH'] = ruby_root + ':' + ENV['PATH']

          begin
            yield
          ensure
            ENV['PATH'] = old_path
          end
        else
          yield
        end
      end

    private

      def initialize
        @path = World.root_path.join('.rubies')
      end
    end
  end
end
