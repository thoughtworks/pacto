module Pacto
  class Validation
    include Logger
    attr_reader :request, :response, :contract, :results

    def initialize(request, response, contract, results)
      @request = request
      @response = response
      @contract = contract
      @results = results
    end

    def successful?
      @results.nil? || @results.empty?
    end

    def against_contract?(contract_pattern)
      return nil if @contract.nil?

      case contract_pattern
      when String
        @contract if @contract.file.eql? contract_pattern
      when Regexp
        @contract if @contract.file =~ contract_pattern
      end
    end

    def to_s
      contract_name = @contract.nil? ? 'nil' : contract.name
      ''"
      Validation:
      \tRequest: #{@request}
      \tContract: #{contract_name}
      \tResults: \n\t\t#{@results.join "\n\t\t"}
      "''
    end

    def summary
      if @contract.nil?
        "Missing contract for services provided by #{@request.uri.host}"
      else
        status = successful? ? 'successful' : 'unsuccessful'
        "#{status} validation of #{@contract.name}"
      end
    end
  end
end
