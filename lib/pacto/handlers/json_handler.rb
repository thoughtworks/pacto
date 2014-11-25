require 'json'

module Pacto
  module Handlers
    module JSONHandler
      class << self
        def raw(body)
          JSON.dump(body)
        end

        def parse(body)
          JSON.parse(body)
        end

        # TODO: Something like validate(contract, body)
      end
    end
  end
end
