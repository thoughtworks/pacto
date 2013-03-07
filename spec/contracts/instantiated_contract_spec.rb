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
      let(:request) do
        double({
          :host => 'http://localhost',
          :method => method,
          :path => '/hello_world',
          :headers => {'Accept' => 'application/json'},
          :params => {'foo' => 'bar'}
        })
      end

      let(:method) { :get }

      let(:response) do
        double({
          :status => 200,
          :headers => {},
          :body => body
        })
      end

      let(:body) do
        {'message' => 'foo'}
      end

      let(:stubbed_request) { double('stubbed request') }

      before do
        WebMock.should_receive(:stub_request).
          with(request.method, "#{request.host}#{request.path}").
          and_return(stubbed_request)

        stubbed_request.stub(:to_return).with({
          :status => response.status,
          :headers => response.headers,
          :body => response.body.to_json
        })
      end

      context 'when the response body is not a String' do
        it 'should stub the response body with a json representation' do
          stubbed_request.should_receive(:to_return).with({
            :status => response.status,
            :headers => response.headers,
            :body => response.body.to_json
          })

          stubbed_request.stub(:with).and_return(stubbed_request)

          described_class.new(request, response).stub!
        end
      end

      context 'when the response body is already a String' do
        let(:body) { "the response" }

        it 'should stub the response body with the same string' do
          stubbed_request.should_receive(:to_return).with({
            :status => response.status,
            :headers => response.headers,
            :body => response.body
          })

          stubbed_request.stub(:with).and_return(stubbed_request)

          described_class.new(request, response).stub!
        end
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
