module Pacto
  module Stubs
    describe WebMockHelper do
      before do
        WebMock.stub_request(:get, 'www.example.com').to_return(:body => 'pacto')
        WebMock.after_request do |request_signature, response|
          @request_signature = request_signature
          @response = response
        end
        HTTParty.get 'http://www.example.com'
      end

      describe '#validate' do
        it 'validates a WebMock request/response pair' do
          described_class.validate @request_signature, @response
        end
      end
    end
  end
end
