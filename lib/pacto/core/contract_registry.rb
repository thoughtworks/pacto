module Pacto
  class ContractNotFound < StandardError; end

  class ContractRegistry < Set
    include Logger

    def register(contract)
      fail ArgumentError, 'expected a Pacto::Contract' unless contract.is_a? Contract
      logger.debug "Registering contract:\n  Name: #{contract.name}\n  Pattern: #{contract.request_pattern}"
      add contract
    end

    def find_by_name(name)
      contract = select { |c| c.name == name }.first
      fail ContractNotFound, "No contract found for #{name}" unless contract
      contract
    end

    def contracts_for(request_signature)
      select { |c| c.matches? request_signature }
    end
  end
end
