module Pacto
  class Configuration
    attr_accessor :adapter, :strict_matchers,
                  :contracts_path, :logger, :generator_options,
                  :hide_deprecations, :default_consumer, :default_provider, :stenographer_log_file
    attr_reader :hook

    def initialize
      @middleware = Pacto::Core::HTTPMiddleware.new
      @middleware.add_observer Pacto::Cops, :investigate
      @generator = Pacto::Generator.new
      @middleware.add_observer @generator, :generate
      @stenographer_log_file ||= File.expand_path('pacto_stenographer.log')
      @default_consumer = Pacto::Consumer
      @default_provider = Pacto::Provider
      @adapter = Stubs::WebMockAdapter.new(@middleware)
      @strict_matchers = true
      @contracts_path = nil
      @logger = Logger::SimpleLogger.instance
      define_logger_level
      @hook = Hook.new {}
      @generator_options = { schema_version: 'draft3' }
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
