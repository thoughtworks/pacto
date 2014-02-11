require 'spec_helper'

module Pacto
  describe URI do
    it 'returns the path appended to the host' do
      uri = URI.new("https://localhost", "/bla")
      expect(uri.to_s).to eq "https://localhost/bla"
    end

    it 'uses http as the default scheme for hosts' do
      uri = URI.new("localhost", "/bla")
      expect(uri.to_s).to eq "http://localhost/bla"
    end
  end
end
