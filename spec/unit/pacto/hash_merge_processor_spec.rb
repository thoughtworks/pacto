module Pacto
  describe HashMergeProcessor do
    describe '#process' do
      let(:response_body_string) { 'a simple string' }
      let(:response_body_hash) do
        {'a' => 'simple hash'}
      end

      it 'does not change contract if values is nil' do
        expect(subject.process(response_body_string, nil)).to eq response_body_string
      end

      it 'merges response body with values' do
        merged_body = {'a' => 'simple hash', 'b' => :key}
        expect(subject.process(response_body_hash, :b => :key)).to eq merged_body.to_s
      end

    end
  end
end
