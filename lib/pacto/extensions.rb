module Pacto
  module Extensions
    # Adapted from Faraday
    HeaderKeyMap = Hash.new do |map, key|
      split_char = key.to_s.include?('-') ? '-' : '_'
      map[key] = key.to_s.split(split_char).     # :user_agent => %w(user agent)
          each { |w| w.capitalize! }.   # => %w(User Agent)
          join('-')                     # => "User-Agent"
    end
    HeaderKeyMap[:etag] = 'ETag'

    def self.normalize_header_keys(headers)
      headers.reduce({}) do |normalized, (key, value)|
        normalized[HeaderKeyMap[key]] = value
        normalized
      end
    end

    module HashSubsetOf
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
