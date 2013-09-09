module Pacto
  class ContractFactory
    def self.build_from_file(contract_path, host, preprocessor)
      
      contract_definition = File.read(contract_path)
      if preprocessor
        contract_definition = preprocessor.process(File.read(contract_path))
      end
      definition = JSON.parse(contract_definition)
      validate_contract definition, contract_path
      request = Request.new(host, definition["request"])
      response = Response.new(definition["response"])
      Contract.new(request, response)
    end
    
    def self.validate_contract definition, contract_path
      contract_format = {
        type: "object",
        required: true,
        properties: {
          request: {
            type: "object",
            required: true,
            properties: {
              method: {type: "string", required: true, pattern: "(GET)|(POST)|(PUT)|(DELETE)"},
              path: {type: "string", required: true},
              params: {type: "object", required: true},
              headers: {type: "object", required: true}
            }
          },
          response: {
            type: "object",
            required: true,
            properties: {
              status: {type: "integer", required: true},
              headers: {type: "object", required: true},
              body: {
                type: "object",
                required: false,
                properties: {
                  type: { type: "string", required: true, pattern: "(string)|(object)|(array)"}
                }
              }
            }
          }
        }
      }.to_json
      errors = JSON::Validator.fully_validate(contract_format, definition)
      unless errors.empty?
        raise InvalidContract, errors.join("\n")
      end
    end
  end
end
