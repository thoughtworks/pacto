module Pacto
  class ResponseClause < Hashie::Dash
    property :status
    property :headers
    property :schema, default: {}
    property :response_builder, default: Pacto::Actors::JSONGenerator
  end
end
