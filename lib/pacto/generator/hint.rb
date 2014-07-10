module Pacto
  class Generator
    class Hint < Hashie::Dash
      property :service_name, required: true
      # property :uri_template, required: true
      property :target_file
    end
  end
end
