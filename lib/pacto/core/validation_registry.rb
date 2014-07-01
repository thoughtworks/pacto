module Pacto
  class ValidationRegistry
    include Singleton
    include Logger
    include Resettable
    attr_reader :validations

    def initialize
      @validations = []
    end

    def self.reset!
      instance.reset!
    end

    def reset!
      @validations.clear
    end

    def validated?(request_pattern)
      matched_validations = @validations.select do |validation|
        request_pattern.matches? validation.request
      end
      matched_validations unless matched_validations.empty?
    end

    def register_validation(validation)
      Pacto.configuration.stenographer.log_validation validation
      @validations << validation
      logger.info "Detected #{validation.summary}"
      validation
    end

    def unmatched_validations
      @validations.select do |validation|
        validation.contract.nil?
      end
    end

    def failed_validations
      @validations.select do |validation|
        !validation.successful?
      end
    end
  end
end
