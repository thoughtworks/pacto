module Pacto
  class Validation
    attr_reader :request, :response, :contract, :results

    def initialize request, response, contract
      @request = request
      @response = response
      @contract = contract
      validate unless contract.nil?
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
