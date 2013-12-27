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

    def use(tag, values = {})
      merged_contracts = registered[:default] + registered[tag]

      fail ArgumentError, "contract \"#{tag}\" not found" if merged_contracts.empty?

      merged_contracts.each do |contract|
        contract.stub_contract! values
      end
      merged_contracts.count
    end

    def load_all(contracts_directory, host, *tags)
      Pacto::Utils.all_contract_files_on(contracts_directory).each { |file| load file, host, *tags }
    end

    def load(contract_file, host, *tags)
      Logger.instance.debug "Registering #{contract_file} with #{tags}"
      contract = build_from_file contract_file, host, nil
      register_contract contract, *tags
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
