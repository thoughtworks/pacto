module JSON
  module Generator
    class ArrayAttribute
      def initialize object_properties
        @props = object_properties
      end

      def generate
        (@props['minItems'] || 0).times.map do |index|
          AttributeFactory.create(@props['items']).generate
        end
      end
    end
  end
end
