module Pacto
  class ResponseClause < Hashie::Dash
    property :status
    property :headers, default: {}
    property :schema, default: {}
  end
end
