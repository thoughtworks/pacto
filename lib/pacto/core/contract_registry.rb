module Pacto
  class ContractRegistry
    def initialize
      @registry = Hash.new { |hash, key| hash[key] = Set.new }
    end

    def [](tag)
      @registry[tag]
    end

    def register(contract)
      @registry[:default] << contract

      self
    end

    def contracts_for(request_signature)
      all_contracts.select { |c| c.matches? request_signature }
    end

    private

    def all_contracts
      @registry.values.inject(Set.new, :+)
    end
  end
end
