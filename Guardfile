guard 'rspec', :cli => '--color --require spec_helper', :version => 2 do
  watch(%r{^spec/pacto/.+_spec\.rb$})
  watch(%r{^spec/json/.+_spec\.rb$})
  watch(%r{^lib/pacto\.rb$})      { |m| "spec" }
  watch(%r{^lib/json-generator\.rb$}) { |m| "spec" }
  watch(%r{^lib/(.+)\.rb$})           { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')        { "spec" }
end
