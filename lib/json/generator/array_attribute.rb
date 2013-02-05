module JSON
  module Generator
    class ArrayAttribute < BasicAttribute
      def generate
        (@attributes['minItems'] || 0).times.map do |index|
          AttributeFactory.create(@attributes['items']).generate
        end
      end
    end
  end
end
