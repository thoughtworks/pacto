module Pacto
  module Stubs
    class StubProvider
      class << self
        def instance
          @instance = Pacto.configuration.provider
        end
      end
    end
  end
end
