module Pacto
  class ContractFactory
    def build_from_file(contract_path, host, preprocessor=NoOpProcessor.new)
      contract_definition = preprocessor.process(File.read(contract_path))
      definition = JSON.parse(contract_definition)
      schema.validate definition
      request = Request.new(host, definition['request'])
      response = Response.new(definition['response'])
      Contract.new(request, response, contract_path)
    end

    def schema
      @schema ||= MetaSchema.new
    end

    def load(contract_name, host = nil)
      build_from_file(path_for(contract_name), host, nil)
    end

    private

    def path_for(contract)
      File.join(Pacto.configuration.contracts_path, "#{contract}.json")
    end
  end

  class NoOpProcessor
    def process(contract_content)
      contract_content
    end
  end
end
