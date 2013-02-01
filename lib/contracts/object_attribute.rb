module Contracts
  class ObjectAttribute
    def initialize attribute
      @props = attribute['type'] == 'object' ? ObjectProperties.expand(attribute) : attribute['properties']
    end

    def generate
      json = {}
      @props.each do |key, properties|
        if properties['required'] == true || properties['required'] == 'true'
          json[key] = AttributeFactory.create(properties).generate
        end
      end
      json
    end
  end
end
