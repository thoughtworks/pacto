# -*- encoding : utf-8 -*-
module Pacto
  module Extensions
    # Adapted from Faraday
    HeaderKeyMap = Hash.new do |map, key|
      split_char = key.to_s.include?('-') ? '-' : '_'
      map[key] = key.to_s.split(split_char).     # :user_agent => %w(user agent)
          each(&:capitalize!).   # => %w(User Agent)
          join('-')                     # => "User-Agent"
    end
    HeaderKeyMap[:etag] = 'ETag'

    def self.normalize_header_keys(headers)
      headers.each_with_object({}) do |(key, value), normalized|
        normalized[HeaderKeyMap[key]] = value
      end
    end
  end
end
