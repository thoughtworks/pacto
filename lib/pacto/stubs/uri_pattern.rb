module Pacto
  class UriPattern
    class << self
      def for(request)
        if request.path.class == Addressable::Template
          build_template_uri_pattern(request)
        elsif Pacto.configuration.strict_matchers
          build_strict_uri_pattern(request)
        else
          build_relaxed_uri_pattern(request)
        end
      end

      def build_template_uri_pattern(request)
        Addressable::Template.new("#{request.host}#{request.path.pattern}")
      end

      def build_strict_uri_pattern(request)
        "#{request.host}#{request.path}"
      end

      def build_relaxed_uri_pattern(request)
        path_pattern = request.path.gsub(/\/:\w+/, '/[^\/\?#]+')
        host_pattern = Regexp.quote(request.host)
        /#{host_pattern}#{path_pattern}(\?.*)?\Z/
      end
    end
  end
end
