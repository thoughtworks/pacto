module Contracts
  class AttributeFactory
    CLASSES = {
      'string' => StringAttribute,
      'object' => ObjectAttribute,
      'integer' => IntegerAttribute,
      'array' => ArrayAttribute
    }

    def self.create(properties)
      CLASSES[properties['type']].new(properties)
    end
  end
end
