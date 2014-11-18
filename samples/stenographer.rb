# -*- encoding : utf-8 -*-
require 'pacto'
Pacto.configure do |c|
  c.contracts_path = 'contracts'
end
contracts = Pacto.load_contracts('contracts', 'http://localhost:5000')
contracts.stub_providers

Pacto.simulate_consumer do
  request 'Echo', values: nil, response: { status: 200 } # 0 contract violations
  request 'Ping', values: nil, response: { status: 200 } # 0 contract violations
  request 'Unknown (http://localhost:8000/404)', values: nil, response: { status: 500 } # 0 contract violations
end

Pacto.simulate_consumer :my_consumer do
  playback 'pacto_stenographer.log'
end
