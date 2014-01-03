module Pacto
  class Hook
    def initialize(&block)
      @hook = block
    end

    def process(contracts, request_signature, response)
      @hook.call contracts, request_signature, response
    end
  end
end
