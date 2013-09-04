module Pacto
	describe InstantiatedContract do
		describe '#replace!' do
      let(:body) { double('body') }
      let(:response) { double(:body => body) }
      let(:values) { double('values') }

      context 'when response body is a hash' do
        let(:normalized_values) { double('normalized values') }
        let(:normalized_body) { double('normalized body') }
        let(:merged_body) { double('merged body') }

        it 'should normalize keys and deep merge response body with given values' do
          values.should_receive(:normalize_keys).and_return(normalized_values)
          response.body.should_receive(:normalize_keys).and_return(normalized_body)
          normalized_body.should_receive(:deep_merge).with(normalized_values).and_return(merged_body)

          instantiated_contract = described_class.new(nil, response)
          instantiated_contract.replace!(values)

          instantiated_contract.response_body.should == merged_body
        end
      end

      context 'when response body is a string' do
        let(:body) { 'foo' }

        it 'should replace response body with given values' do
          instantiated_contract = described_class.new(nil, response)
          instantiated_contract.replace!(values)
          instantiated_contract.response_body.should == values
        end
      end

      context 'when response body is nil' do
        let(:body) { nil }

        it 'should replace response body with given values' do
          instantiated_contract = described_class.new(nil, response)
          instantiated_contract.replace!(values)
          instantiated_contract.response_body.should == values
        end
      end
    end

    describe '#response_body' do
      let(:response) { double(:body => double('body')) }

      it "should return response body" do
        described_class.new(nil, response).response_body.should == response.body
      end
    end

    describe '#request_path' do
      let(:request) { double('request', :absolute_uri => "http://dummy_link/hello_world") }
      let(:response) { double('response', :body => double('body')) }

      it "should return the request absolute uri" do
        described_class.new(request, response).request_path.should == "http://dummy_link/hello_world"
      end
    end

    describe '#request_uri' do
      let(:request) { double('request', :full_uri => "http://dummy_link/hello_world?param=value#fragment") }
      let(:response) { double('response', :body => double('body')) }

      it "should return request full uri" do
        described_class.new(request, response).request_uri.should == "http://dummy_link/hello_world?param=value#fragment"
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
