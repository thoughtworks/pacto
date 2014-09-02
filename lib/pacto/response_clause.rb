module Pacto
  class ResponseClause < Hashie::Dash
    include Hashie::Extensions::IndifferentAccess
    property :status
    property :headers, default: {}
    property :schema, default: {}
  end
end
