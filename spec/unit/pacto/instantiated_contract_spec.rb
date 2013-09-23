module Pacto
  describe InstantiatedContract do

    describe '#response' do
      let(:response) { double(:body => double('body')) }

      it 'should return response' do
        described_class.new(nil, response).response.should == response
      end
    end

  end
end
