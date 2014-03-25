require 'pacto/rspec'
require 'pacto/test_helper'

describe 'ping service' do
  include Pacto::TestHelper

  it 'pongs' do
    with_pacto(
      :port => 5000,
      :backend_host => 'http://localhost:9292',
      :live => true,
      :stub => false,
      :generate => false,
      :directory => 'contracts'
      ) do |pacto_endpoint|
      # call your code
      system "curl #{pacto_endpoint}/api/ping"
    end

    # check results
    expect(Pacto).to have_validated(:get, 'http://localhost:9292/api/ping')
  end
end
