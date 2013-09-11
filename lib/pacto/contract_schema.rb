module Pacto
  module Schema
    class ContractSchema
      
      def initialize(definition)
        @definition = definition
      end
      
      def validate(response_body)
        JSON::Validator.fully_validate(@definition['properties']['response'], response_body)
      end
      
    end
  end
end
