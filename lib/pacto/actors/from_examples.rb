# -*- encoding : utf-8 -*-
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
    class FromExamples < Actor
      def initialize(fallback_actor = JSONGenerator.new, selector = Pacto::Actors::FirstExampleSelector)
        @fallback_actor = fallback_actor
        @selector = selector
      end

      def build_request(contract, values = {})
        request_values = (values || {}).dup
        if contract.examples?
          example = @selector.select(contract.examples, values)
          data = contract.request.to_hash
          request_values.merge! example_uri_values(contract)
          data['uri'] = contract.request.uri(request_values)
          data['body'] = example.request.body
          data['method'] = contract.request.http_method
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

      def example_uri_values(contract)
        uri_template = contract.request.pattern.uri_template
        if contract.examples && contract.examples.values.first[:request][:uri]
          example_uri = contract.examples.values.first[:request][:uri]
          uri_template.extract example_uri
        else
          {}
        end
      end
    end
  end
end
