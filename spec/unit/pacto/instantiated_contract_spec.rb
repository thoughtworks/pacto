module Pacto
  describe InstantiatedContract do

    describe '#response_body' do
      let(:response) { double(:body => double('body')) }

      it 'should return response body' do
        described_class.new(nil, response).response_body.should == response.body
      end
    end

    describe '#request_path' do
      let(:request) { double('request', :absolute_uri => 'http://dummy_link/hello_world') }
      let(:response) { double('response', :body => double('body')) }

      it 'should return the request absolute uri' do
        described_class.new(request, response).request_path.should == 'http://dummy_link/hello_world'
      end
    end

    describe '#request_uri' do
      let(:request) { double('request', :full_uri => 'http://dummy_link/hello_world?param=value#fragment') }
      let(:response) { double('response', :body => double('body')) }

      it 'should return request full uri' do
        described_class.new(request, response).request_uri.should == 'http://dummy_link/hello_world?param=value#fragment'
      end
    end

    describe '#stub!' do
      let(:request) { double :request }
      let(:response) { double :response, body: double(:body) }
      let(:stub_provider) { double :stub_provider }

      before do
        Pacto::Stubs::StubProvider.stub(instance: stub_provider)
      end

      it 'delegates the stubbing to the current stub provider' do
        stub_provider.should_receive(:stub!).with(request, response, response.body)
        described_class.new(request, response).stub!
      end
    end
  end
end
