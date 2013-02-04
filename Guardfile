guard 'rspec', :cli => '--color --require spec_helper', :version => 2 do
  watch(%r{^spec/contracts/.+_spec\.rb$})
  watch(%r{^lib/contracts\.rb$}) { |m| "spec" }
  watch(%r{^lib/(.+)\.rb$})      { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')   { "spec" }
end
