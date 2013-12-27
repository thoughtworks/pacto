module Pacto
  class MetaSchema
    attr_accessor :schema, :engine

    def initialize(engine = JSON::Validator)
      @schema = File.join(File.dirname(File.expand_path(__FILE__)), '../../resources/contract_schema.json')
      @base_schema = File.join(File.dirname(File.expand_path(__FILE__)), '../../resources/draft-03.json')
      JSON::Validator.cache_schemas = true
      JSON::Validator.validate!(@base_schema, @schema)
      @engine = engine
    end

    def validate(definition)
      errors = engine.fully_validate(schema, definition, :version => :draft3)
      unless errors.empty?
        fail InvalidContract, errors
      end
    end
  end
end
