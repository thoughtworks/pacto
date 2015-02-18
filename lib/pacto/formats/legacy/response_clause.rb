module Pacto
  module Formats
    module Legacy
      class ResponseClause
        include Pacto::ResponseClause
        extend Forwardable
        attr_reader :data
        def_delegators :data, :to_hash
        def_delegators :data, :status, :headers, :schema
        def_delegators :data, :status=, :headers=, :schema=

        class Data < Pacto::Dash
          property :status
          property :headers, default: {}
          property :schema, default: {}
        end

        def initialize(data)
          skip_freeze = data.delete(:skip_freeze)
          @data = Data.new(data)
          freeze unless skip_freeze
        end

        def freeze
          @data.freeze
          self
        end
      end
    end
  end
end
