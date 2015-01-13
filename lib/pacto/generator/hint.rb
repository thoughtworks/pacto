# -*- encoding : utf-8 -*-
module Pacto
  module Generator
    class Hint < Pacto::Dash
      extend Forwardable
      property :service_name, required: true
      property :target_file
      attr_reader :request_clause
      def_delegators :@request_clause, *RequestClause.instance_methods(false)

      def initialize(data, request_clause)
        @request_clause = request_clause
        super(data)
        self.target_file ||= "#{slugify(service_name)}.json"
        self
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
