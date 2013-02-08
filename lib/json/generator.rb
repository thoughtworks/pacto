require "json/generator/basic_attribute"
require "json/generator/string_attribute"
require "json/generator/integer_attribute"
require "json/generator/array_attribute"
require "json/generator/object_attribute"
require "json/generator/boolean_attribute"
require "json/generator/attribute_factory"
require "json/generator/dereferencer"

module JSON
  module Generator
    def self.generate(schema)
      dereferenced_schema = Dereferencer.dereference(schema)
      AttributeFactory.create(dereferenced_schema).generate
    end
  end
end
