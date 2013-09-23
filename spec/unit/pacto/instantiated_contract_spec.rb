module Pacto
  describe InstantiatedContract do

    describe '#response' do
      let(:response) { double(:body => double('body')) }

      it 'should return response' do
        described_class.new(nil, response).response.should == response
      end
    end

    describe '#stub!' do
      let(:request) { double :request }
      let(:response) { double :response, body: double(:body) }
      let(:stub_provider) { double :stub_provider }

      it 'delegates the stubbing to the current stub provider' do
        Pacto.configure do |c|
          c.provider = stub_provider
        end
        stub_provider.should_receive(:stub!).with(request, response)
        described_class.new(request, response).stub!
      end
    end
  end
end
