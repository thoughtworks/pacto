module Pacto
  module Generator
    class Hint < Pacto::RequestClause
      property :service_name, required: true
      property :target_file

      def matches?(pacto_request)
        return false if pacto_request.nil?
        Pacto::RequestPattern.for(self).matches?(pacto_request)
      end
    end
  end
end
