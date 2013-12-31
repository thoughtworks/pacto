module Pacto
  class ContractRegistry
    def register_contract(contract = nil, *tags)
      tags << :default if tags.empty?

      tags.uniq.each do |tag|
        registered[tag] << contract
      end

      self
    end

    def use(tag, values = {})
      merged_contracts = registered[:default] + registered[tag]

      fail ArgumentError, "contract \"#{tag}\" not found" if merged_contracts.empty?

      merged_contracts.each do |contract|
        contract.stub_contract! values
      end

      self
    end

    def registered
      @registered ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def unregister_all!
      registered.clear
    end

    def contracts_for(request_signature)
      matches = Set.new
      registered.values.each do |contract_set|
        contract_set.each do |contract|
          if contract.matches? request_signature
            matches.add contract
          end
        end
      end
      matches
    end

    def contract_for(request_signature)
      contracts_for(request_signature).first
    end
  end
end
