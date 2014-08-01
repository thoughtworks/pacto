require 'pacto'
Pacto.load_contracts 'contracts', 'http://localhost:5000'
WebMock.allow_net_connect!

interactions = Pacto.simulate_consumer :my_client do
  request 'Ping'
  request 'Echo', body: ->(body) { body.reverse },
                  headers: (proc do |headers|
                    headers['Content-Type'] = 'text/json'
                    headers['Accept'] = 'none'
                    headers
                  end)
end
puts interactions
