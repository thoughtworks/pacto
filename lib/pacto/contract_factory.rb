module Pacto
  class ContractFactory
    def self.contract_schema
      File.join(File.dirname(File.expand_path(__FILE__)), '../../resources/contract_schema.json')
    end

    def self.build_from_file(contract_path, host, file_pre_processor)
      contract_definition_expanded = file_pre_processor.process(File.read(contract_path))
      definition = JSON.parse(contract_definition_expanded)
      validate_contract definition
      request = Request.new(host, definition["request"])
      response = Response.new(definition["response"])
      Contract.new(request, response)
    end
    
    def self.validate_contract definition
      errors = JSON::Validator.fully_validate(contract_schema, definition)
      unless errors.empty?
        raise InvalidContract.new(errors)
      end
    end
  end
end
