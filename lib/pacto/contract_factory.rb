module Pacto
  class ContractFactory
    def self.build_from_file(contract_path, host, preprocessor)
      contract_definition = File.read(contract_path)
      if preprocessor
        contract_definition = preprocessor.process(contract_definition)
      end
      definition = JSON.parse(contract_definition)
      schema.validate definition
      request = Request.new(host, definition['request'])
      response = Response.new(definition['response'])
      Contract.new(request, response, contract_path)
    end

    def self.schema
      @schema ||= MetaSchema.new
    end

    def self.load(contract_name, host = nil)
      build_from_file(path_for(contract_name), host)
    end

    private

    def self.path_for(contract)
      File.join(Pacto.configuration.contracts_path, "#{contract}.json")
    end
  end
end
