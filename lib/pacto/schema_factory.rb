module Pacto
  class SchemaFactory
    
    def self.build_from_file(schema)
      contract_schema_file = File.read(path_for(schema))
      definition = JSON.parse(contract_schema_file)
      validate_schema definition, schema
    end
    
    private
    def self.path_for (schema)
      File.join(File.dirname(File.expand_path(__FILE__)), "../../resources/schemas/#{schema}.json")
    end
    
    def self.contract_schema
      File.join(File.dirname(File.expand_path(__FILE__)), '../../resources/contract_schema.json')
    end
    
    def self.validate_schema definition
      errors = JSON::Validator.fully_validate(contract_schema, definition)
      unless errors.empty?
        raise InvalidContract.new(errors)
      end
    end
  end
end
