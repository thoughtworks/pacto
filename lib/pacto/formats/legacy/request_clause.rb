# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Legacy
      class RequestClause < Pacto::Dash
        include Pacto::RequestClause
        extend Forwardable
        attr_reader :data
        def_delegators :data, :to_hash
        def_delegators :data, :host, :http_method, :schema, :path, :headers, :params
        def_delegators :data, :host=, :http_method=, :schema=, :path=, :headers=, :params=

        class Data < Pacto::Dash
          property :host # required?
          property :http_method, required: true
          property :schema, default: {}
          property :path, default: '/'
          property :headers, default: {}
          property :params, default: {}
        end

        def initialize(data)
          skip_freeze = data.delete(:skip_freeze)
          mash = Hashie::Mash.new data
          mash['http_method'] = normalize(mash['http_method'])
          @data = Data.new(mash)
          freeze unless skip_freeze
          super({})
        end

        def freeze
          @data.freeze
          self
        end
      end
    end
  end
end
