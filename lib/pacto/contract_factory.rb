module Pacto
  class ContractFactory
    def self.build_from_file(contract_path, host, preprocessor)
      contract_definition = File.read(contract_path)
      if preprocessor
        contract_definition = preprocessor.process(contract_definition)
      end
      definition = JSON.parse(contract_definition)
      schema.validate definition
      request = Request.new(host, definition["request"])
      response = Response.new(definition["response"])
      Contract.new(request, response)
    end

    def self.schema
      @schema ||= MetaSchema.new
    end
  end
end
