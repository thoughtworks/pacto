module Pacto
  class ResponseClause < Hashie::Dash
    property :status
    property :headers
    property :schema, default: {}
    property :response_builder, default: Pacto::Actors::JSONGenerator

    def to_pacto_response
      response_builder.build_response self
    end
  end
end
