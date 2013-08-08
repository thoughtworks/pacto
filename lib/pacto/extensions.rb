module Pacto
  module Extensions
    module HashSubsetOf
      def subset_of?(other)
        (self.to_a - other.to_a).empty?
      end

      def normalize_keys
        self.inject({}) do |normalized, (key, value)|
          normalized[key.to_s.downcase] = value
          normalized
        end
      end
    end
  end
end

Hash.send(:include, Pacto::Extensions::HashSubsetOf)
