module Contracts
  module Extensions
    module HashSubsetOf
      def subset_of?(other)
        (self.to_a - other.to_a).empty?
      end
    end
  end
end

Hash.send(:include, Contracts::Extensions::HashSubsetOf)
