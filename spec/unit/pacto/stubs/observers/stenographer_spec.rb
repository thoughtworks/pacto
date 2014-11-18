# -*- encoding : utf-8 -*-
require 'spec_helper'

module Pacto
  module Observers
    describe Stenographer do
      let(:pacto_request) { Fabricate(:pacto_request) }
      let(:pacto_response) { Fabricate(:pacto_response) }
      let(:contract) { Fabricate(:contract) }
      let(:citations) { %w(one two) }
      let(:investigation) { Pacto::Investigation.new(pacto_request, pacto_response, contract, citations) }

      subject(:stream) { StringIO.new }

      subject { described_class.new stream }

      it 'writes to the stenographer log stream' do
        subject.log_investigation investigation
        expected_log_line = "request #{contract.name.inspect}, values: {}, response: {status: #{pacto_response.status}} # #{citations.size} contract violations\n"
        expect(stream.string).to eq expected_log_line
      end

      context 'when the stenographer log stream is nil' do
        let(:stream) { nil }

        it 'does nothing' do
          # Would raise an error if it tried to write to stream
          subject.log_investigation investigation
        end
      end
    end
  end
end
