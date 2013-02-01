class ObjectProperties
	def self.definitions=(defs)
		@@definitions = defs
	end

	def self.expand(object_definition)
		object_definition['properties'] ||
			find_ref(@@definitions || {}, object_definition['$ref'])
	end

	private
	def self.find_ref(definitions, ref)
		keys = ref[2..-1].split('/')
		value = definitions[keys[1]] || {}
		keys[2..-1].each {|k| value = value[k] || {}}
		value['properties']
	end
end
