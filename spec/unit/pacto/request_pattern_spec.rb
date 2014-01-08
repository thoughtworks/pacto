require 'spec_helper'

module Pacto
  describe RequestPattern do
    let(:method) { :get  }
    let(:uri_pattern) { double }
    let(:request_pattern) { double }
    let(:request) { double(method: method) }

    it 'returns a pattern that combines the contracts method and uri_pattern' do
      expect(UriPattern).to receive(:for).
        with(request).
        and_return(uri_pattern)

      expect(WebMock::RequestPattern).to receive(:new).
        with(method, uri_pattern).
        and_return(request_pattern)

      expect(RequestPattern.for(request)).to eq request_pattern
    end
  end
end
