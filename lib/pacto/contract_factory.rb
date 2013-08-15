module Pacto
  class ContractFactory
    def self.build_from_file(contract_path, host, file_pre_processor)
      contract_definition_expanded = file_pre_processor.process(File.read(contract_path))
      definition = JSON.parse(contract_definition_expanded)
      request = Request.new(host, definition["request"])
      response = Response.new(definition["response"])
      Contract.new(request, response)
    end
  end
end
