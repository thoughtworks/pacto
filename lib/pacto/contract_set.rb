module Pacto
  class ContractSet < Set
    def stub_providers(values = {})
      each { |contract| contract.stub_contract!(values) }
    end

    def simulate_consumers
      map { |contract| contract.simulate_request }
    end
  end
end
