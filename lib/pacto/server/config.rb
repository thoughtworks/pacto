def token_map
  if File.readable? '.tokens.json'
    MultiJson.load(File.read '.tokens.json')
  else
    {}
  end
end

def prepare_contracts(contracts)
  contracts.stub_providers if options[:stub]
end

config[:backend_host] = options[:backend_host] ||= 'https://localhost'
config[:strip_port] = options[:strip_port]
config[:strip_dev] = options[:strip_dev]
config[:port] = port
contracts_path = options[:directory] || File.expand_path('contracts', Dir.pwd)
Pacto.configure do |pacto_config|
  pacto_config.logger = logger
  pacto_config.contracts_path = contracts_path
  pacto_config.strict_matchers = options[:strict]
  pacto_config.generator_options = {
    schema_version: :draft3,
    token_map: token_map
  }
  pacto_config.stenographer_log_file = options[:stenographer_log_file]
end

if options[:generate]
  Pacto.generate!
  logger.info 'Pacto generation mode enabled'
end

if options[:recursive_loading]
  Dir["#{contracts_path}/*"].each do |host_dir|
    host = File.basename host_dir
    prepare_contracts Pacto.load_contracts(host_dir, "https://#{host}")
  end
else
  prepare_contracts Pacto.load_contracts contracts_path, options[:backend_host]
end

Pacto.validate! if options[:validate]

if options[:live]
  #  WebMock.reset!
  WebMock.allow_net_connect!
end
