module JSON
	module Generator
		class BasicAttribute
			def initialize(attributes)
				@attributes = attributes
			end

			def generate
				@attributes['default'] || self.class::DEFAULT_VALUE
			end

			def required?
				@attributes['required']
			end
		end
	end
end
