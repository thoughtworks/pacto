module Pacto
  class Callback
    def initialize(&block)
      @callback = block
    end

    def process(contracts, request_signature, response)
      @callback.call contracts, request_signature, response
    end
  end
end
