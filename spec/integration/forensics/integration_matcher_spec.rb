# -*- encoding : utf-8 -*-
require 'pacto/rspec'

module Pacto
  describe '#have_investigated' do
    let(:contract_path) { 'spec/fixtures/contracts/simple_contract.json' }
    let(:strict_contract_path) { 'spec/fixtures/contracts/strict_contract.json' }

    def expect_to_raise(message_pattern = nil, &blk)
      expect { blk.call }.to raise_error(RSpec::Expectations::ExpectationNotMetError, message_pattern)
    end

    def json_response(url)
      response = Faraday.get(url) do |req|
        req.headers = { 'Accept' => 'application/json' }
      end
      MultiJson.load(response.body)
    end

    def play_bad_response
      contracts.stub_providers(device_id: 1.5)
      Faraday.get('http://dummyprovider.com/strict') do |req|
        req.headers = { 'Accept' => 'application/json' }
      end
    end

    context 'successful investigations' do
      let(:contracts) do
        Pacto.load_contracts 'spec/fixtures/contracts/', 'http://dummyprovider.com'
      end

      before(:each) do
        Pacto.configure do |c|
          c.strict_matchers = false
          c.register_hook Pacto::Hooks::ERBHook.new
        end

        contracts.stub_providers(device_id: 42)
        Pacto.validate!

        Faraday.get('http://dummyprovider.com/api/hello') do |req|
          req.headers = { 'Accept' => 'application/json' }
        end
      end

      it 'performs successful assertions' do
        # High level assertions
        expect(Pacto).to_not have_unmatched_requests
        expect(Pacto).to_not have_failed_investigations

        # Increasingly strict assertions
        expect(Pacto).to have_investigated('Simple Contract')
        expect(Pacto).to have_investigated('Simple Contract').with_request(headers: hash_including('Accept' => 'application/json'))
        expect(Pacto).to have_investigated('Simple Contract').with_request(http_method: :get, url: 'http://dummyprovider.com/api/hello')
      end

      it 'supports negative assertions' do
        expect(Pacto).to_not have_investigated('Strict Contract')
        Faraday.get('http://dummyprovider.com/strict') do |req|
          req.headers = { 'Accept' => 'application/json' }
        end
        expect(Pacto).to have_investigated('Strict Contract')
      end

      it 'raises useful error messages' do
        # Expected failures
        header_matcher  = hash_including('Accept' => 'text/plain')
        matcher_description = Regexp.quote(header_matcher.description)
        expect_to_raise(/but no requests matched headers #{matcher_description}/) { expect(Pacto).to have_investigated('Simple Contract').with_request(headers: header_matcher) }
      end

      it 'displays Contract investigation problems' do
        play_bad_response
        expect_to_raise(/investigation errors were found:/) { expect(Pacto).to have_investigated('Strict Contract') }
      end

      it 'displays the Contract file' do
        play_bad_response
        schema_file_uri = Addressable::URI.convert_path(File.absolute_path strict_contract_path).to_s
        expect_to_raise(/in schema #{schema_file_uri}/) { expect(Pacto).to have_investigated('Strict Contract') }
      end
    end
  end
end
