module Pacto
  class ResponseClause < Hashie::Dash
    property :status
    property :headers
    property :schema, default: {}
  end
end
