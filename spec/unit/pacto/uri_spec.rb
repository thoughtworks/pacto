require 'spec_helper'

module Pacto
  describe URI do
    it 'returns the path appended to the host' do
      uri = URI.for('https://localtest.me', '/bla')
      expect(uri.to_s).to eq 'https://localtest.me/bla'
    end

    it 'uses http as the default scheme for hosts' do
      uri = URI.for('localtest.me', '/bla')
      expect(uri.to_s).to eq 'http://localtest.me/bla'
    end

    it 'shows query parameters if initialized with params' do
      uri = URI.for('localtest.me', '/bla', 'param1' => 'ble')
      expect(uri.to_s).to eq 'http://localtest.me/bla?param1=ble'
    end
  end
end
