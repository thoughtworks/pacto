# -*- encoding : utf-8 -*-
require 'hashie/mash'

module Pacto
  class PactoRequest
    # FIXME: Need case insensitive header lookup, but case-sensitive storage
    attr_accessor :headers, :body, :method, :uri

    def initialize(data)
      data.singleton_class.send(:include, Hashie::Extensions::IndifferentAccess)
      @headers = data[:headers].nil? ? {} : data[:headers]
      @body    = data[:body]
      @method  = data[:method]
      @uri     = data[:uri]
      normalize
    end

    def to_hash
      {
        method: method,
        uri: uri,
        headers: headers,
        body: body
      }
    end

    def to_s
      string = Pacto::UI.colorize_method(method)
      string << " #{relative_uri}"
      string << " with body (#{raw_body.bytesize} bytes)" if body
      string
    end

    def relative_uri
      uri.to_s.tap do |s|
        s.slice!(uri.normalized_site)
      end
    end

    def raw_body
      return body if body.is_a? String

      case content_type
      when 'application/json', nil
        JSON.dump(body)
      else
        fail NotImplementedError, "No encoder for #{body.class} to #{content_type}"
      end
    end

    def parsed_body
      if body.is_a?(String) && content_type == 'application/json'
        JSON.parse(body)
      else
        body
      end
    rescue
      body
    end

    def content_type
      headers['Content-Type']
    end

    def normalize
      @method = @method.to_s.downcase.to_sym
      @uri = @uri.normalize if @uri
    end
  end
end
