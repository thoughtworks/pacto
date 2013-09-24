module Pacto
  class MetaSchema
    attr_accessor :schema, :engine

    def initialize(engine = JSON::Validator)
      @schema = File.join(File.dirname(File.expand_path(__FILE__)), '../../resources/contract_schema.json')
      @engine = engine
    end

    def validate definition
      errors = engine.fully_validate(schema, definition, :version => :draft3)
      unless errors.empty?
        raise InvalidContract.new(errors)
      end
    end
  end
end
