module Pacto
  module Extensions
    module HashSubsetOf
      def subset_of?(other)
        (to_a - other.to_a).empty?
      end

      def normalize_keys
        reduce({}) do |normalized, (key, value)|
          normalized[key.to_s.downcase] = value
          normalized
        end
      end
    end

    module ColoredString
      def colorize(*args)
        self
      end
    end
  end
end

String.send(:include, Pacto::Extensions::ColoredString) unless String.respond_to?(:colors)
Hash.send(:include, Pacto::Extensions::HashSubsetOf)
