# -*- encoding : utf-8 -*-
require 'spec_helper'

module Pacto
  describe RequestPattern do
    let(:http_method) { :get  }
    let(:uri_pattern) { double }
    let(:request_pattern) { double }
    let(:request) { double(http_method: http_method) }

    it 'returns a pattern that combines the contracts http_method and uri_pattern' do
      expect(UriPattern).to receive(:for).
        with(request).
        and_return(uri_pattern)

      expect(Pacto::RequestPattern).to receive(:new).
        with(http_method, uri_pattern).
        and_return(request_pattern)

      expect(RequestPattern.for(request)).to eq request_pattern
    end
  end
end
