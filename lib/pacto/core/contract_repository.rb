module Pacto
  class << self

    def register_contract(contract = nil, *tags)
      tags.uniq.each do |tag|
        registered[tag] << contract
      end
      nil
    end

    def use(tag, values = nil)
      merged_contracts = registered[:default].merge registered[tag]

      raise ArgumentError, "contract \"#{tag}\" not found" if merged_contracts.empty?

      configuration.provider.values = values

      merged_contracts.inject(Set.new) do |result, contract|
        instantiated_contract = contract.instantiate
        instantiated_contract.stub!
        result << instantiated_contract
      end
    end

    def registered
      @registered ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def unregister_all!
      registered.clear
    end
  end
end
