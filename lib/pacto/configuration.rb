module Pacto
  class Configuration
    attr_accessor :preprocessor, :postprocessor, :provider, :strict_matchers, :contracts_path, :logger

    def initialize
      @preprocessor = ERBProcessor.new
      @postprocessor = HashMergeProcessor.new
      @provider = Pacto::Stubs::BuiltIn.new
      @strict_matchers = true
      @contracts_path = nil
      @logger = Logger.instance
      @logger.level = :debug if ENV['PACTO_DEBUG']
    end
  end
end
