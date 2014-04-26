module Pacto
  class ResponseClause < Hashie::Dash
    property :status
    property :headers
    property :schema, default: {}

    def body
      @body ||= JSON::Generator.generate(schema)
    end
  end
end
