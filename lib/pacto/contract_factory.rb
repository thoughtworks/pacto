module Pacto
  class ContractFactory
    attr_reader :preprocessor, :schema

    def initialize(options = {})
      @preprocessor = options[:preprocessor] || NoOpProcessor.new
      @schema = options[:schema] || MetaSchema.new
    end

    def build_from_file(contract_path, host)
      contract_definition = preprocessor.process(File.read(contract_path))
      definition = JSON.parse(contract_definition)
      schema.validate definition
      request = Request.new(host, definition['request'])
      response = Response.new(definition['response'])
      Contract.new(request, response, contract_path)
    end
  end

  class NoOpProcessor
    def process(contract_content)
      contract_content
    end
  end
end
