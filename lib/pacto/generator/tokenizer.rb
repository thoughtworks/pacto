require 'jsonpath'
module Pacto
  class Generator
    class Tokenizer
      def initialize(token_map = Pacto.configuration.generator_options[:token_map])
        @token_map = token_map || {}
      end

      def tokenize(contract)
        return contract if @token_map.empty?

        JsonPath.for(contract).gsub!('$.request.path') do |path|
          tokenize_value path
        end
        # TODO: Weird jsonpath is due to https://github.com/joshbuddy/jsonpath/issues/28.
        # JsonPath.for(contract).gsub!('$.request.headers[?(true)]') do |headers|
        #   headers.map do |key, value|
        #     headers[key] = tokenize_value value
        #   end
        # end
        contract
      end

      def tokenize_value(value)
        @token_map.each do |k, v|
          value.gsub! v, k.inspect
        end
        value
      end
    end
  end
end
