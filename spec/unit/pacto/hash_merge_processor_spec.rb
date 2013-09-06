module Pacto
  describe HashMergeProcessor do
    describe "#process" do
      let (:contract) { double('instantiated contract')}
      let (:response_body_string) { "a simple string" }
      let (:response_body_hash) {
        {'a' => 'simple hash'}
      }

      it "should not change contract if values is nil" do
        contract.should_receive(:response_body).and_return(response_body_string)
        subject.process(contract, nil).response_body.should == response_body_string
      end
      
      it "should merge response body with values" do
        merged_body = {'a' => 'simple hash', "b" => :key}
        contract.should_receive(:response_body).twice.and_return(response_body_hash)
        contract.should_receive(:response_body=).with(merged_body)
        # subject.process(contract, {:b => :key}).response_body.should == merged_body
      end

    end
  end
end