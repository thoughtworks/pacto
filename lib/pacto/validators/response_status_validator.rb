module Pacto
  module Validators
    class ResponseStatusValidator
      def initialize(app)
        @app = app
      end

      def call env
        expected_status = env[:contract].response.status
        actual_status = env[:actual_response].status
        env[:validation_results].concat self.class.validate(expected_status, actual_status)
        @app.call env
      end

      def self.validate expected_status, actual_status
        errors = []
        if expected_status != actual_status
          errors << "Invalid status: expected #{expected_status} but got #{actual_status}"
        end
        errors
      end
    end
  end
end
