require 'webmock'
require 'webmock/rspec'

class WebMock::RequestSignature
  def inspect
    to_s
  end
end

describe 'request signatures' do
  let(:request_signatures) do
    5.times.map { |n| WebMock::RequestSignature.new(:get, "http://www.google.com/#{n}") }
  end

  it 'only calls google' do
    expect(request_signatures).to contain_exactly(5.times.map { a_request :get, 'www.google.com' })
  end
end
