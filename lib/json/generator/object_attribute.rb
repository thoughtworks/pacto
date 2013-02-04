module JSON
	module Generator
		class ObjectAttribute
			def initialize(attributes)
				@attributes = attributes
			end

			def generate
				return nil unless @attributes['required']
				return {} unless @attributes.has_key?('properties')
				@attributes['properties'].inject({}) do |json, (property_name, property_attributes)|
					json[property_name] = AttributeFactory.create(property_attributes).generate
					json
				end
			end
		end
	end
end
