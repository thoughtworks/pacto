module Pacto
  class Configuration
    attr_accessor :provider, :strict_matchers,
                  :contracts_path, :logger, :generator_options
    attr_reader :hook

    def initialize
      @provider = Stubs::WebMockAdapter.new
      @strict_matchers = true
      @contracts_path = nil
      @logger = Logger::SimpleLogger.instance
      define_logger_level
      @hook = Hook.new {}
      @generator_options = { :schema_version => 'draft3' }
    end

    def register_hook(hook = nil, &block)
      if block_given?
        @hook = Hook.new(&block)
      else
        fail 'Expected a Pacto::Hook' unless hook.is_a? Hook
        @hook = hook
      end
    end

    private

    def define_logger_level
      if ENV['PACTO_DEBUG']
        @logger.level = :debug
      else
        @logger.level = :default
      end
    end
  end
end
