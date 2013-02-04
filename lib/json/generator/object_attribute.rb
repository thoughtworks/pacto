module JSON
	module Generator
		class ObjectAttribute < BasicAttribute
			def generate
				return nil unless required?
				return {} unless @attributes.has_key?('properties')
				@attributes['properties'].inject({}) do |json, (property_name, property_attributes)|
					json[property_name] = AttributeFactory.create(property_attributes).generate
					json
				end
			end
		end
	end
end
