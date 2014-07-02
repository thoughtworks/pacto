require 'polytrix'

Polytrix.configure do |polytrix|
  polytrix.implementor name: 'pacto', basedir: "#{Dir.pwd}/samples"
end
