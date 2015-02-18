# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Legacy
      class RequestClause < Pacto::RequestClause
        def initalize(data)
          super
          freeze
        end
      end
    end
  end
end
