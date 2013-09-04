module Pacto
  module Stubs
    class StubProvider
      class << self
        def instance
          @instance = BuiltIn.new
        end
      end
    end
  end
end
