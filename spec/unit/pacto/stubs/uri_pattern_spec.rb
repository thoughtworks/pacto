require 'spec_helper'

module Pacto
  describe UriPattern do
    context 'with non-strict matchers' do
      it 'returns a regex containing the host and path' do
        Pacto.configuration.strict_matchers = false
        request = double(host: 'myhost.com', path: '/stuff')
        expect(UriPattern.for(request)).to eq(/myhost\.com\/stuff/)
      end
    end

    context 'with strict matchers' do
      it 'returns a string with the host and path' do
        Pacto.configuration.strict_matchers = true
        request = double(host: 'myhost.com', path: '/stuff')
        expect(UriPattern.for(request)).to eq('myhost.com/stuff')
      end
    end
  end
end
