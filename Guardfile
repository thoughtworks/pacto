guard :rspec do
  # Unit tests
  watch(%r{^spec/unit/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})            { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')         { "spec/unit" }
  watch('spec/unit/spec_helper.rb')    { "spec/unit" }
  watch(%r{^spec/unit/data/.+\.json$}) { "spec/unit" }

  # Integration tests
  watch(%r{^spec/integration/.+_spec\.rb$})
  watch(%r{^spec/integration/utils/.+\.rb$})  { "spec/integration" }
  watch(%r{^lib/.+.rb$})                      { "spec/integration" }
  watch('spec/spec_helper.rb')                { "spec/integration" }
  watch('spec/integration/spec_helper.rb')    { "spec/integration" }
  watch(%r{^spec/integration/data/.+\.json$}) { "spec/integration" }
end

guard :rubocop do
  watch(%r{.+\.rb$})
  watch('.rubocop.yml')      { '.' }
  watch('.rubocop-todo.yml') { '.' }
end
