module JSON
  module Generator
    class AttributeFactory
      CLASSES = {
        'string' => StringAttribute,
        'object' => ObjectAttribute,
        'integer' => IntegerAttribute,
        'array' => ArrayAttribute,
        'boolean' => BooleanAttribute
      }

      def self.create(properties)
        CLASSES[Array(properties['type']).first].new(properties)
      end
    end
  end
end
