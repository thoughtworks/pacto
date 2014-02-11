require 'spec_helper'

module Pacto
  describe URI do
    it 'returns the path appended to the host' do
      uri = URI.new("https://localhost", "/bla")
      expect(uri.to_s).to eq "https://localhost/bla"
    end
  end
end
