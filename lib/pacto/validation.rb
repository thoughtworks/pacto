module Pacto
  class Validation
    attr_reader :request, :response, :contract, :results

    def initialize request, response, contract
      @request = request
      @response = response
      @contract = contract
      validate unless contract.nil?
    end

    def successful?
      @results.nil? || @results.empty?
    end

    def against_contract? contract_pattern
      unless @contract.nil?
        case contract_pattern
        when String
          @contract if @contract.file.eql? contract_pattern
        when Regexp
          @contract if @contract.file =~ contract_pattern
        end
      end
    end

    private

    def logger
      @logger ||= Logger.instance
    end

    def validate
      logger.debug("Validating #{@request}, #{@response} against #{@contract}")
      @results = contract.validate(response)
    end
  end
end
