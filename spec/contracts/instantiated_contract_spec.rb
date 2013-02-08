module Contracts
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

    describe '#stub!' do
      let(:request) do
        double({
          :host => 'http://localhost',
          :method => method,
          :path => '/hello_world',
          :headers => {'Accept' => 'application/json'},
          :params => {'foo' => 'bar'}
        })
      end

      let(:response) do
        double({
          :status => 200,
          :headers => {},
          :body => {'message' => 'foo'}
        })
      end

      let(:stubbed_request) { double('stubbed request') }

      before do
        WebMock.should_receive(:stub_request).
          with(request.method, "#{request.host}#{request.path}").
          and_return(stubbed_request)

        stubbed_request.should_receive(:to_return).with({
          :status => response.status,
          :headers => response.headers,
          :body => response.body.to_json
        })
      end

      context 'a GET request' do
        let(:method) { :get }

        it 'should use WebMock to stub the request' do
          stubbed_request.should_receive(:with).
            with({:headers => request.headers, :query => request.params}).
            and_return(stubbed_request)
          described_class.new(request, response).stub!
        end
      end

      context 'a POST request' do
        let(:method) { :post }

        it 'should use WebMock to stub the request' do
          stubbed_request.should_receive(:with).
            with({:headers => request.headers, :body => request.params}).
            and_return(stubbed_request)
          described_class.new(request, response).stub!
        end
      end

      context 'a request with no headers' do
        let(:request) do
          double({
            :host => 'http://localhost',
            :method => :get,
            :path => '/hello_world',
            :headers => {},
            :params => {'foo' => 'bar'}
          })
        end

        it 'should use WebMock to stub the request' do
          stubbed_request.should_receive(:with).
            with({:query => request.params}).
            and_return(stubbed_request)
          described_class.new(request, response).stub!
        end
      end

      context 'a request with no params' do
        let(:request) do
          double({
            :host => 'http://localhost',
            :method => :get,
            :path => '/hello_world',
            :headers => {},
            :params => {}
          })
        end

        it 'should use WebMock to stub the request' do
          stubbed_request.should_receive(:with).
            with({}).
            and_return(stubbed_request)
          described_class.new(request, response).stub!
        end
      end
    end
	end
end
