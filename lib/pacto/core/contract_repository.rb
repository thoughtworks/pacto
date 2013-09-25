module Pacto
  class << self

    def register_contract(contract = nil, *tags)
      tags << :default if tags.empty?
      start_count = registered.count
      tags.uniq.each do |tag|
        registered[tag] << contract
      end
      registered.count - start_count
    end

    def use(tag, values = nil)
      merged_contracts = registered[:default].merge registered[tag]

      raise ArgumentError, "contract \"#{tag}\" not found" if merged_contracts.empty?

      configuration.provider.values = values

      merged_contracts.each do |contract|
        contract.stub!
      end
      merged_contracts.count
    end

    def registered
      @registered ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def unregister_all!
      registered.clear
    end

    def contract_for(request_signature)
      registered.values.inject(Set.new) do |result, contract_set|
        result.merge(contract_set.keep_if { |c| c.matches? request_signature })
      end
    end
  end
end
