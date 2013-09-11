module Pacto
  module Schema
    class SchemaFactory
      
      def self.build_from_file(schema)
        schema_file = File.read(path_for(schema))
        schema_definition = JSON.parse(schema_file)
        ContractSchema.new schema_definition
      end
      
      private
      def self.path_for (schema)
        File.join(File.dirname(File.expand_path(__FILE__)), "../../resources/schemas/#{schema}.json")
      end
    end
  end
end
