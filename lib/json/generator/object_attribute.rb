module JSON
  module Generator
    class ObjectAttribute < BasicAttribute
      def generate
        return nil unless required?
        return {} unless @attributes.has_key?('properties')

        @attributes['properties'].inject({}) do |json, (property_name, property_attributes)|
          attribute = AttributeFactory.create(property_attributes)
          if attribute.required?
            json[property_name] = attribute.generate
          end
          json
        end
      end
    end
  end
end
