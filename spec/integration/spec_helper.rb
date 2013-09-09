require_relative 'utils/dummy_server'

require "aruba"
require "aruba/in_process"
Aruba.process = Aruba::InProcess
class Aruba::InProcess
  attr_reader :stdin

  def self.main_class;
    @@main_class;
  end

  self.main_class = Class.new do
    @@input = ""
    class << self
      def input
        @@input
      end
    end

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel

      def @stdin.noecho
        yield self
      end

      @stdin << @@input
      @stdin.rewind
    end

    def execute!
      old_stdin, old_stdout, old_stderr, old_kernel = $stdin, $stdout, $stderr, $kernel
      $stdin, $stdout, $stderr, $kernel = @stdin, @stdout, @stderr, @kernel
      begin
        @kernel.exit Rake.application.run @argv, @stdin, @stdout, @stderr
      ensure
        $stdin, $stdout, $stderr, $kernel = old_stdin, old_stdout, old_stderr, old_kernel
      end
    end
  end
end