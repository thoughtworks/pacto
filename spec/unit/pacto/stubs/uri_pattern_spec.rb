require 'spec_helper'

module Pacto
  describe UriPattern do
    context 'with non-strict matchers' do
      before(:each) do
        Pacto.configuration.strict_matchers = false
      end

      it 'appends host if path is an Addressable::Template' do
        path_pattern = '/{account}/data{.format}{?page,per_page}'
        path = Addressable::Template.new path_pattern
        request = double(host: 'https://www.example.com', path: path)
        expect(UriPattern.for(request).pattern).to eq(Addressable::Template.new("https://www.example.com#{path_pattern}").pattern)
      end

      it 'returns a regex containing the host and path' do
        request = double(host: 'myhost.com', path: '/stuff')
        expect(UriPattern.for(request).to_s).to include('myhost\.com')
        expect(UriPattern.for(request).to_s).to include('\/stuff')
      end

      it 'turns segments preceded by : into wildcards' do
        request = double(host: 'myhost.com', path: '/:id')
        wildcard = '[^\/\?#]+'
        expect(UriPattern.for(request).to_s).to include(wildcard)
        expect(UriPattern.for(request).to_s).to_not include(':id')
      end

      it 'creates a regex that does not allow additional path elements' do
        request = double(host: 'myhost.com', path: '/:id')
        pattern = UriPattern.for(request)
        expect(pattern).to match('myhost.com/foo')
        expect(pattern).to_not match('myhost.com/foo/bar')
      end

      it 'creates a regex that does allow query parameters' do
        request = double(host: 'myhost.com', path: '/:id')
        pattern = UriPattern.for(request)
        expect(pattern).to match('myhost.com/foo?a')
        expect(pattern).to match('myhost.com/foo?a=b')
        expect(pattern).to match('myhost.com/foo?a=b&c=d')
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
