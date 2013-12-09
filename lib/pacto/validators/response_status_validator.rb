module Pacto
  module Validators
    class ResponseStatusValidator
      def self.validate expected_status, actual_status
        if expected_status != actual_status
          return ["Invalid status: expected #{expected_status} but got #{actual_status}"]
        end
      end
    end
  end
end
