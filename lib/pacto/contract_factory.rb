module Pacto
  class ContractFactory
    attr_reader :schema

    def initialize(options = {})
      @schema = options[:schema] || MetaSchema.new
    end

    def build(contract_files, host)
      contract_files.map { |file| build_from_file(file, host) }
    end

    def build_from_file(contract_path, host)
      contract_definition = File.read(contract_path)
      definition = JSON.parse(contract_definition)
      schema.validate definition
      request = RequestClause.new(host, definition['request'])
      response = Response.new(definition['response'])
      Contract.new(request, response, contract_path, definition['name'])
    end
  end
end
