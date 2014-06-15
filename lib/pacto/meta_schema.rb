module Pacto
  class MetaSchema
    attr_accessor :schema, :engine

    def initialize(engine = JSON::Validator)
      @schema = File.join(File.dirname(File.expand_path(__FILE__)), '../../resources/contract_schema.json')
      base_schemas = ['../../resources/draft-03.json', '../../resources/draft-04.json']
      validatable = false
      base_schemas.each do |base_schema|
        base_schema_file = File.join(File.dirname(File.expand_path(__FILE__)), base_schema)
        # This has a side-effect of caching local schemas, so we don't
        # look up json-schemas over HTTP.
        validatable ||= JSON::Validator.validate(base_schema_file, @schema)
      end
      fail 'Could not validate metaschema against any known version of json-schema' unless validatable
      @engine = engine
    end

    def validate(definition)
      errors = engine.fully_validate(schema, definition)
      fail InvalidContract, errors unless errors.empty?
    end
  end
end
