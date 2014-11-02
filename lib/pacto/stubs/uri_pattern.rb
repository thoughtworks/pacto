# -*- encoding : utf-8 -*-
module Pacto
  class UriPattern
    class << self
      def for(request, strict = Pacto.configuration.strict_matchers)
        fix_deprecations(request)

        build_template_uri_pattern(request, strict)
      end

      def build_template_uri_pattern(request, strict)
        path = request.path.respond_to?(:pattern) ? request.path.pattern : request.path
        host = request.host ||= '{server}'
        scheme, host = host.split('://') if host.include?('://')
        scheme ||= '{scheme}'

        if strict
          Addressable::Template.new("#{scheme}://#{host}#{path}")
        else
          Addressable::Template.new("#{scheme}://#{host}#{path}{?anyvars*}")
        end
      end

      def fix_deprecations(request)
        return if request.path.is_a? Addressable::Template
        return if request.path == (corrected_path = request.path.gsub(/\/:(\w+)/, '/{\\1}'))

        Pacto::UI.deprecation "Please change path #{request.path} to uri template: #{corrected_path}"
        request.path = Addressable::Template.new(corrected_path)
      end
    end
  end
end
