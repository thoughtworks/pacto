# -*- encoding : utf-8 -*-

module Pacto
  module Handlers
    autoload :JSONHandler, 'pacto/handlers/json_handler'
    autoload :TextHandler, 'pacto/handlers/text_handler'
    autoload :XMLHandler,  'pacto/handlers/xml_handler'
  end
  module BodyParsing
    def raw_body
      return nil if body.nil?
      return body if body.respond_to? :to_str

      body_handler.raw(body)
    end

    def parsed_body
      return nil if body.nil?

      body_handler.parse(body)
    end

    def content_type
      headers['Content-Type']
    end

    def body_handler
      case content_type
      when /\bjson$/
        Pacto::Handlers::JSONHandler
      when /\btext$/
        Pacto::Handlers::TextHandler
      # No XML support - yet
      # when /\bxml$/
      #   XMLHandler
      else
        # JSON is still the default
        Pacto::Handlers::JSONHandler
      end
    end
  end
end
