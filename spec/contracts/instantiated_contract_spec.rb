module Contracts
	describe InstantiatedContract do
		pending '#replace!'

    describe '#stub!' do
      let(:request) do
        double({
          :method => method,
          :path => '/hello_world',
          :headers => {},
          :params => {}
        })
      end

      let(:response) do
        double({
          :status => 200,
          :headers => {},
          :body => 'foo'
        })
      end

      let(:stubbed_request) { double('stubbed request') }

      before do
        WebMock.should_receive(:stub_request).
          with(request.method, "http://foo.com#{request.path}").
          and_return(stubbed_request)

        stubbed_request.should_receive(:to_return).with({
          :status => response.status,
          :headers => response.headers,
          :body => response.body
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
    end
	end
end
