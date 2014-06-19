module Pacto
  class ContractRegistry < Set
    include Logger

    def register(contract)
      fail ArgumentError, 'expected a Pacto::Contract' unless contract.is_a? Contract
      logger.debug "Registering contract for #{contract.request_pattern}"
      add contract
    end

    def contracts_for(request_signature)
      select { |c| c.matches? request_signature }
    end
  end
end
