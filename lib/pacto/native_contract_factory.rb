module Pacto
  # Builds {Pacto::Contract} instances from Pacto's native Contract format.
  class NativeContractFactory
    attr_reader :schema

    def initialize(options = {})
      @schema = options[:schema] || MetaSchema.new
    end

    def build_from_file(contract_path, host)
      contract_definition = File.read(contract_path)
      definition = JSON.parse(contract_definition)
      schema.validate definition
      definition['request'].merge!('host' => host)
      body_to_schema(definition, 'request')
      body_to_schema(definition, 'response')
      request = RequestClause.new(definition['request'])
      response = ResponseClause.new(definition['response'])
      Contract.new(request: request, response: response, file: contract_path, name: definition['name'])
    end

    private

    def body_to_schema(definition, section)
      schema = definition[section].delete 'body'
      if schema
        Pacto::UI.deprecation "Contract format deprecation: #{section}:body will be moved to #{section}:schema"
        definition[section]['schema'] = schema
      end
    end
  end
end
