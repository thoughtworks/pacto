# -*- encoding : utf-8 -*-
require 'pacto/formats/legacy/request_clause'
require 'pacto/formats/legacy/response_clause'

module Pacto
  module Formats
    module Legacy
      class Contract < Pacto::Dash
        include Pacto::Contract

        property :id
        property :file
        property :request,  required: true
        # Although I'd like response to be required, it complicates
        # the partial contracts used the rake generation task...
        # yet another reason I'd like to deprecate that feature
        property :response # , required: true
        property :values, default: {}
        # Gotta figure out how to use test doubles w/ coercion
        coerce_key :request,  RequestClause
        coerce_key :response, ResponseClause
        property :examples
        property :name, required: true
        property :adapter, default: proc { Pacto.configuration.adapter }
        property :consumer, default: proc { Pacto.configuration.default_consumer }
        property :provider, default: proc { Pacto.configuration.default_provider }

        def initialize(opts)
          skip_freeze = opts.delete(:skip_freeze)

          if opts[:file]
            opts[:file] = Addressable::URI.convert_path(File.expand_path(opts[:file])).to_s
            opts[:name] ||= opts[:file]
          end
          opts[:id] ||= (opts[:summary] || opts[:file])
          super
          freeze unless skip_freeze
        end
      end
    end
  end
end
