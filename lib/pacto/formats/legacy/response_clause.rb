module Pacto
  module Formats
    module Legacy
      class ResponseClause < Pacto::Dash
        include Pacto::ResponseClause

        property :status
        property :headers, default: {}
        property :schema, default: {}

        def initalize(data)
          super
          freeze
        end
      end
    end
  end
end
