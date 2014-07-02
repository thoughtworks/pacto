module Pacto
  module Validators
    class ResponseHeaderValidator
      def self.validate(_request, response, contract)
        expected_headers = contract.response.headers
        actual_headers = response.headers
        actual_headers = Pacto::Extensions.normalize_header_keys actual_headers
        headers_to_validate = Pacto::Extensions.normalize_header_keys expected_headers

        headers_to_validate.map do |expected_header, expected_value|
          if actual_headers.key? expected_header
            actual_value = actual_headers[expected_header]
            HeaderValidatorMap[expected_header].call(expected_value, actual_value)
          else
            "Missing expected response header: #{expected_header}"
          end
        end.compact
      end

      private

      HeaderValidatorMap = Hash.new do |_map, key|
        proc do |expected_value, actual_value|
          unless expected_value.eql? actual_value
            "Invalid response header #{key}: expected #{expected_value.inspect} but received #{actual_value.inspect}"
          end
        end
      end

      HeaderValidatorMap['Location'] = proc do |expected_value, actual_value|
        location_template = Addressable::Template.new(expected_value)
        if location_template.match(Addressable::URI.parse(actual_value))
          nil
        else
          "Invalid response header Location: expected URI #{actual_value} to match URI Template #{location_template.pattern}"
        end
      end
    end
  end
end
