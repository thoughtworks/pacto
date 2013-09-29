module Pacto
  describe HashMergeProcessor do
    describe '#process' do
      let(:response_body_string) { 'a simple string' }
      let(:response_body_hash) {
        {'a' => 'simple hash'}
      }

      it 'does not change contract if values is nil' do
        subject.process(response_body_string, nil).should == response_body_string
      end

      it 'merges response body with values' do
        merged_body = {'a' => 'simple hash', 'b' => :key}
        subject.process(response_body_hash, {:b => :key}).should == merged_body.to_s
      end

    end
  end
end
