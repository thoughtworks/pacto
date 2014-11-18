# -*- encoding : utf-8 -*-
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
        request = Fabricate(:request_clause, host: 'https://www.example.com', path: path)
        expect(UriPattern.for(request).pattern).to include(Addressable::Template.new("https://www.example.com#{path_pattern}").pattern)
      end

      it 'returns a URITemplate containing the host and path and wildcard vars' do
        request = Fabricate(:request_clause, host: 'myhost.com', path: '/stuff')
        uri_pattern = UriPattern.for(request)
        expect(uri_pattern.pattern).to eql('myhost.com/stuff{?anyvars*}')
      end

      it 'convers segments preceded by : into variables', :deprecated do
        request = Fabricate(:request_clause, host: 'myhost.com', path: '/:id')
        uri_pattern = UriPattern.for(request)
        expect(uri_pattern.keys).to include('id')
        expect(uri_pattern.pattern).to_not include(':id')
      end

      it 'creates a regex that does not allow additional path elements' do
        request = Fabricate(:request_clause, host: 'myhost.com', path: '/:id')
        pattern = UriPattern.for(request)
        expect(pattern).to match('myhost.com/foo')
        expect(pattern).to_not match('myhost.com/foo/bar')
      end

      it 'creates a regex that does allow query parameters', :deprecated do
        request = Fabricate(:request_clause, host: 'myhost.com', path: '/:id')
        pattern = UriPattern.for(request)
        expect(pattern.match('myhost.com/foo?a=b')). to be_truthy
        expect(pattern.match('myhost.com/foo?a=b&c=d')).to be_truthy
      end
    end

    # Strict/relaxed matching should be done against the full URI or path only
    context 'with strict matchers', deprecated: true do
      it 'returns a string with the host and path' do
        Pacto.configuration.strict_matchers = true
        request = Fabricate(:request_clause, host: 'myhost.com', path: '/stuff')
        uri_pattern = UriPattern.for(request)
        expect(uri_pattern.pattern).to eq('myhost.com/stuff')
      end
    end
  end
end
