# Pacto has a few RSpec matchers to help you ensure a **consumer** and **producer** are
# interacting properly. First, let's setup the rspec suite.
require 'rspec/autorun' # Not generally needed
require 'pacto/rspec'
WebMock.allow_net_connect!
Pacto.validate!
Pacto.load_contracts('contracts', 'http://localhost:5000').stub_providers

# It's usually a good idea to reset Pacto between each scenario. `Pacto.reset` just clears the
# data and metrics about which services were called. `Pacto.clear!` also resets all configuration
# and plugins.
RSpec.configure do |c|
  c.after(:each)  { Pacto.reset }
end

# Pacto provides some RSpec matchers related to contract testing, like making sure
# Pacto didn't received any unrecognized requests (`have_unmatched_requests`) and that
# the HTTP requests matched up with the terms of the contract (`have_failed_investigations`).
describe Faraday do
  let(:connection) { described_class.new(url: 'http://localhost:5000') }

  it 'passes contract tests' do
    connection.get '/api/ping'
    expect(Pacto).to_not have_failed_investigations
    expect(Pacto).to_not have_unmatched_requests
  end
end

# There are also some matchers for collaboration testing, so you can make sure each scenario is
# calling the expected services and sending the right type of data.
describe Faraday do
  let(:connection) { described_class.new(url: 'http://localhost:5000') }
  before(:each) do
    connection.get '/api/ping'

    connection.post do |req|
      req.url '/api/echo'
      req.headers['Content-Type'] = 'application/json'
      req.body = '{"foo": "bar"}'
    end
  end

  it 'calls the ping service' do
    expect(Pacto).to have_validated(:get, 'http://localhost:5000/api/ping').against_contract('Ping')
  end

  it 'sends data to the echo service' do
    expect(Pacto).to have_investigated('Echo').with_request(body: hash_including('foo' => 'bar'))
    expect(Pacto).to have_investigated('Echo').with_response(body: hash_including('foo' => 'bar'))
  end
end
