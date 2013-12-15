module Pacto
  module Extensions
    # Adapted from Faraday
    KeyMap = Hash.new do |map, key|
      split_char = key.to_s.include?('-') ? '-' : '_'
      map[key] = key.to_s.split(split_char).     # :user_agent => %w(user agent)
          each { |w| w.capitalize! }.   # => %w(User Agent)
          join('-')                     # => "User-Agent"
    end
    KeyMap[:etag] = 'ETag'

    def self.normalize_header_keys headers
      headers.reduce({}) do |normalized, (key, value)|
        normalized[KeyMap[key]] = value
        normalized
      end
    end

    module HashSubsetOf
      def subset_of?(other)
        (to_a - other.to_a).empty?
      end

      # FIXME: Only used by HashMergeProcessor, which I'd like to deprecate
      def normalize_keys
        reduce({}) do |normalized, (key, value)|
          normalized[key.to_s.downcase] = value
          normalized
        end
      end
    end
  end
end

# FIXME: Let's not extend Hash...
Hash.send(:include, Pacto::Extensions::HashSubsetOf)
