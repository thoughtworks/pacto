module Pacto
  class Configuration
    attr_accessor :preprocessor, :postprocessor, :provider, :strict_matchers,
                  :contracts_path, :logger, :generator_options
    attr_reader :callback

    def initialize
      @preprocessor = ERBProcessor.new
      @postprocessor = HashMergeProcessor.new
      @provider = Pacto::Stubs::BuiltIn.new
      @strict_matchers = true
      @contracts_path = nil
      @logger = Logger.instance
      define_logger_level
      @callback = Pacto::Hooks::ERBHook.new
      @generator_options = { :schema_version => 'draft3' }
    end

    def register_callback(callback = nil, &block)
      if block_given?
        @callback = Pacto::Callback.new(&block)
      else
        fail 'Expected a Pacto::Callback' unless callback.is_a? Pacto::Callback
        @callback = callback
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
