require 'pacto/generator/native_contract_generator'
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
    end

    class Configuration
      def initialize
        @hints = Set.new
      end

      def hint(name, hint_data)
        @hints << Pacto::Generator::Hint.new(hint_data.merge(service_name: name))
      end
    end
  end
end
