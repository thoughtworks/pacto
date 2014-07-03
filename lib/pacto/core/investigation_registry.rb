module Pacto
  class InvestigationRegistry
    include Singleton
    include Logger
    include Resettable
    attr_reader :investigations

    def initialize
      @investigations = []
    end

    def self.reset!
      instance.reset!
    end

    def reset!
      @investigations.clear
    end

    def validated?(request_pattern)
      matched_investigations = @investigations.select do |investigation|
        request_pattern.matches? investigation.request
      end
      matched_investigations unless matched_investigations.empty?
    end

    def register_investigation(investigation)
      @investigations << investigation
      logger.info "Detected #{investigation.summary}"
      investigation
    end

    def unmatched_investigations
      @investigations.select do |investigation|
        investigation.contract.nil?
      end
    end

    def failed_investigations
      @investigations.select do |investigation|
        !investigation.successful?
      end
    end
  end
end
