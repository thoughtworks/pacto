module Pacto
  module Handlers
    module TextHandler
      class << self
        def raw(body)
          body.to_s
        end

        def parse(body)
          body.to_s
        end

        # TODO: Something like validate(contract, body)
      end
    end
  end
end
