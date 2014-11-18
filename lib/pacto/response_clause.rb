# -*- encoding : utf-8 -*-
module Pacto
  class ResponseClause < Pacto::Dash
    property :status
    property :headers, default: {}
    property :schema, default: {}
  end
end
