# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Legacy
      class GeneratorHint < Pacto::Dash
        extend Forwardable

        property :request_clause
        coerce_key :request_clause, RequestClause
        property :service_name, required: true
        property :target_file

        def_delegators :request_clause, *RequestClause::Data.properties.map(&:to_sym)

        def initialize(data)
          data[:request_clause] = RequestClause::Data.properties.each_with_object({}) do | prop, hash |
            hash[prop] = data.delete prop
          end
          super
          self.target_file ||= "#{slugify(service_name)}.json"
        end

        def matches?(pacto_request)
          return false if pacto_request.nil?
          Pacto::RequestPattern.for(request_clause).matches?(pacto_request)
        end

        private

        def slugify(path)
          path.downcase.gsub(' ', '_')
        end
      end
    end
  end
end
