module Pacto
  module Validators
    class RequestBodyValidator < BodyValidator
      def initialize(app)
        @app = app
      end

      def self.section_name
        'request'
      end

      def self.subschema(contract)
        contract.request.schema
      end

      def call(env)
        if env[:validation_results].empty? # skip body validation if we already have other errors
          actual_body = env[:actual_request]
          errors = self.class.validate(env[:contract], actual_body)
          env[:validation_results].concat errors.compact
        end
        @app.call env
      end
    end
  end
end
