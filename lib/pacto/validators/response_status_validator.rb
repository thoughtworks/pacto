module Pacto
  module Validators
    class ResponseStatusValidator
      def initialize(app)
        @app = app
      end

      def call env
        definition = env[:response_definition]
        response = env[:actual_response]
        env[:validation_results] << validate(definition['status'], response.status)
        @app.call env
      end

      def validate expected_status, actual_status
        if expected_status != actual_status
          return ["Invalid status: expected #{expected_status} but got #{actual_status}"]
        end
      end
    end
  end
end
