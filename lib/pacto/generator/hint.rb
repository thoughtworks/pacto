# -*- encoding : utf-8 -*-
module Pacto
  module Generator
    class Hint < Pacto::RequestClause
      property :service_name, required: true
      property :target_file

      def initialize(data)
        super
        self.target_file ||= "#{slugify(service_name)}.json"
        self
      end

      def matches?(pacto_request)
        return false if pacto_request.nil?
        Pacto::RequestPattern.for(self).matches?(pacto_request)
      end

      private

      def slugify(path)
        path.downcase.gsub(' ', '_')
      end
    end
  end
end
