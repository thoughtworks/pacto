module Pacto
  module Actors
    class FirstExampleSelector
      def self.select(examples, _values)
        Hashie::Mash.new examples.values.first
      end
    end
    class RandomExampleSelector
      def self.select(examples, _values)
        Hashie::Mash.new examples.values.sample
      end
    end
    class NamedExampleSelector
      def self.select(examples, values)
        name = values[:example_name]
        if name.nil?
          RandomExampleSelector.select(examples, values)
        else
          Hashie::Mash.new examples[name]
        end
      end
    end
    class FromExamples
      def initialize(fallback_actor = JSONGenerator, selector = Pacto::Actors::FirstExampleSelector)
        @fallback_actor = fallback_actor
        @selector = selector
      end

      def build_request(contract, values = {})
        if contract.examples?
          example = @selector.select(contract.examples, values)
          data = contract.request.to_hash
          data['uri'] = contract.request.uri
          data['body'] = example.request.body
          Pacto::PactoRequest.new(data)
        else
          @fallback_actor.build_request contract, values
        end
      end

      def build_response(contract, values = {})
        if contract.examples?
          example = @selector.select(contract.examples, values)
          data = contract.response.to_hash
          data['body'] = example.response.body
          Pacto::PactoResponse.new(data)
        else
          @fallback_actor.build_response contract, values
        end
      end
    end
  end
end
