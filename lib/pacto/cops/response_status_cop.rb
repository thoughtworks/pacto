module Pacto
  module Cops
    class ResponseStatusCop
      def self.investigate(_request, response, contract)
        expected_status = contract.response.status
        actual_status = response.status
        errors = []
        if expected_status != actual_status
          errors << "Invalid status: expected #{expected_status} but got #{actual_status}"
        end
        errors
      end
    end
  end
end
