# -*- encoding : utf-8 -*-
require 'pacto'
require 'hashie/mash'

# Fabricators for contracts or parts of contracts

DEFAULT_PACTO_FORMAT = (ENV['DEFAULT_PACTO_FORMAT'] || 'legacy')

Fabricator(:delegating_fabricator, from: Object) do
  transient format: DEFAULT_PACTO_FORMAT
  transient :thing
  initialize_with do
    transients = _transient_attributes.dup
    format = transients.delete :format
    thing = transients.delete :thing
    fabricator = "#{format.to_s}_#{thing.to_s}".to_sym
    data = to_hash.merge(transients)
    Fabricate(fabricator, data)
  end
end

Fabricator(:contract, from: :delegating_fabricator) do
  transient thing: :contract
  transient example_count: 0
end

Fabricator(:partial_contract, from: :delegating_fabricator) do
  transient thing: :partial_contract
end

Fabricator(:request_clause, from: :delegating_fabricator) do
  transient thing: :request_clause
end

Fabricator(:response_clause, from: :delegating_fabricator) do
  transient thing: :response_clause
end

Fabricator(:schema, from: :delegating_fabricator) do
  transient thing: :schema
  transient :version
end

Fabricator(:an_example, from: :delegating_fabricator) do
  transient thing: :an_example
    transient name: 'default'
end
