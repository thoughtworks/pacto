module JSON
  module Generator
    class Dereferencer
      def self.dereference(schema)
        return schema unless schema.has_key?('properties')

        definitions = schema.delete('definitions')
        schema['properties'].each do |name, property|
          next unless property.has_key?('$ref')

          ref_name = property['$ref'].split('/').last
          raise NameError, "definition for #{ref_name} not found" unless definitions.has_key?(ref_name)

          property.merge!(definitions[ref_name])
          property.delete('$ref')
        end

        schema
      end
    end
  end
end
