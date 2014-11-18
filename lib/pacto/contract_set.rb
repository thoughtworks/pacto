# -*- encoding : utf-8 -*-
module Pacto
  class ContractSet < Set
    def stub_providers(values = {})
      each { |contract| contract.stub_contract!(values) }
    end

    def simulate_consumers
      map(&:simulate_request)
    end
  end
end
