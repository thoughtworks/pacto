# -*- encoding : utf-8 -*-
module Pacto
  module BodyParsing
    def raw_body
      return nil if body.nil?
      return body if body.respond_to? :to_str

      case content_type
      when /\bjson$/
        JSON.dump(body)
      else
        # Going w/ JSON as the default for now
        JSON.dump(body)
      end
    end

    def parsed_body
      return nil if body.nil?

      case content_type
      when /\bjson$/
        JSON.parse(body)
      when /\btext$/
        body
      else
        # Going w/ JSON as the default for now
        JSON.parse(body)
      end
    end

    def content_type
      headers['Content-Type']
    end
  end
end
