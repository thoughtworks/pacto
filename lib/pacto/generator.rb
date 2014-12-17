# -*- encoding : utf-8 -*-
require 'pacto/generator/legacy_contract_generator'
require 'pacto/generator/hint'

module Pacto
  module Generator
    include Logger

    class << self
      # Factory method to return the active contract generator implementation
      def contract_generator
        NativeContractGenerator.new
      end

      # Factory method to return the active contract generator implementation
      def schema_generator
        JSON::SchemaGenerator
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def hint_for(pacto_request)
        configuration.hints.find { |hint| hint.matches? pacto_request }
      end
    end

    class Configuration
      attr_reader :hints

      def initialize
        @hints = Set.new
      end

      def hint(name, hint_data)
        @hints << Pacto::Generator::Hint.new(hint_data.merge(service_name: name))
      end
    end
  end
end
