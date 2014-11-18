# -*- encoding : utf-8 -*-
module Pacto
  describe ERBProcessor do
    subject(:processor) { described_class.new }

    describe '#process' do
      let(:erb) { '2 + 2 = <%= 2 + 2 %>' }
      let(:result) { '2 + 2 = 4' }

      it 'returns the result of ERB' do
        expect(processor.process(erb)).to eq result
      end

      it 'logs the erb processed' do
        expect(Pacto.configuration.logger).to receive(:debug).with("Processed contract: \"#{result}\"")
        processor.process erb
      end

      it 'does not mess with pure JSONs' do
        processor.process('{"property": ["one", "two, null"]}')
      end
    end
  end
end
