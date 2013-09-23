module Pacto
  describe ERBProcessor do
    subject(:processor) { ERBProcessor.new }

    describe '#process' do
      let(:erb) { '2 + 2 = <%= 2 + 2 %>' }
      let(:result) { '2 + 2 = 4' }

      it 'should return the result of ERB' do
        expect(processor.process(erb)).to eq result
      end

      it 'logs the erb processed' do
        Logger.instance.should_receive(:debug).with("Processed contract: \"#{result}\"")
        processor.process erb
      end

      it 'should not mess with pure JSONs' do
        processor.process('{"property": ["one", "two, null"]}')
      end
    end
  end
end
