module Pacto
  module Generator
    class Hint < Hashie::Dash
      property :service_name, required: true
      # property :uri_template, required: true
      property :target_file
      property :http_method
      property :uri_template
    end
  end
end
