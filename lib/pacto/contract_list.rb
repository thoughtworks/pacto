module Pacto
  class ContractList
    attr_reader :contracts

    def initialize(contracts)
      @contracts = contracts
    end

    def stub_providers(values = {})
      contracts.each { |contract| contract.stub_contract!(values) }
    end

    def simulate_consumers
      contracts.map { |contract| contract.simulate_request }
    end
  end
end
