module Pacto
  module Stubs
    describe WebMockAdapter do
      let(:middleware) { double }

      let(:request) do
        double(
          :host => 'http://localhost',
          :method => method,
          :path => '/hello_world',
          :headers => {'Accept' => 'application/json'},
          :params => {'foo' => 'bar'}
        )
      end

      let(:method) { :get }

      let(:response) do
        double(
          :status => 200,
          :headers => {},
          :body => body
        )
      end

      let(:body) do
        {'message' => 'foo'}
      end

      let(:stubbed_request) do
        {
          :path => nil
        }
      end

      let(:request_pattern) { double('request_pattern') }

      subject(:adapter) { WebMockAdapter.new middleware }

      before(:each) do
        stubbed_request.stub(:to_return).with(
          :status => response.status,
          :headers => response.headers,
          :body => response.body.to_json
        )
        stubbed_request.stub(:request_pattern).and_return request_pattern
      end

      describe '#initialize' do
        it 'sets up a hook' do
          WebMock.should_receive(:after_request) do | arg, &block |
            expect(block.parameters).to have(2).items
          end

          # WebMockAdapter.new
          Pacto.configuration.provider # this way the rpec after block doesn't create a second instance
        end
      end

      describe '#process_hooks' do
        let(:request_signature) { double('request_signature') }

        it 'calls the middleware for processing' do
          expect(middleware).to receive(:process).with(a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end
      end

      describe '#stub_request!' do
        before(:each) do
          WebMock.should_receive(:stub_request) do | method, url |
            stubbed_request[:path] = url
            stubbed_request
          end
        end

        context 'when the response body is an object' do
          let(:body) do
            {'message' => 'foo'}
          end

          it 'stubs the response body with a json representation' do
            stubbed_request.should_receive(:to_return).with(
              :status => response.status,
              :headers => response.headers,
              :body => response.body.to_json
            )

            request_pattern.stub(:with)

            adapter.stub_request! request, response
          end

          context 'when the response body is an array' do
            let(:body) do
              [1, 2, 3]
            end

            it 'stubs the response body with a json representation' do
              stubbed_request.should_receive(:to_return).with(
                :status => response.status,
                :headers => response.headers,
                :body => response.body.to_json
              )

              request_pattern.stub(:with)

              adapter.stub_request! request, response
            end
          end

          context 'when the response body is not an object or an array' do
            let(:body) { nil }

            it 'stubs the response body with the original body' do
              stubbed_request.should_receive(:to_return).with(
                :status => response.status,
                :headers => response.headers,
                :body => response.body
              )

              request_pattern.stub(:with)

              adapter.stub_request! request, response
            end
          end

          context 'a GET request' do
            let(:method) { :get }

            it 'uses WebMock to stub the request' do
              request_pattern.should_receive(:with).
                with(:headers => request.headers, :query => request.params).
                and_return(stubbed_request)
              adapter.stub_request! request, response
            end
          end

          context 'a POST request' do
            let(:method) { :post }

            it 'uses WebMock to stub the request' do
              request_pattern.should_receive(:with).
                with(:headers => request.headers, :body => request.params).
                and_return(stubbed_request)
              adapter.stub_request! request, response
            end
          end

          context 'a request with no headers' do
            let(:request) do
              double(
                :host => 'http://localhost',
                :method => :get,
                :path => '/hello_world',
                :headers => {},
                :params => {'foo' => 'bar'}
              )
            end

            it 'uses WebMock to stub the request' do
              request_pattern.should_receive(:with).
                with(:query => request.params).
                and_return(stubbed_request)
              adapter.stub_request! request, response
            end
          end

          context 'a request with no params' do
            let(:request) do
              double(
                :host => 'http://localhost',
                :method => :get,
                :path => '/hello_world',
                :headers => {},
                :params => {}
              )
            end

            it 'uses WebMock to stub the request' do
              request_pattern.should_receive(:with).
                with({}).
                and_return(stubbed_request)
              adapter.stub_request! request, response
            end
          end
        end
      end
    end
  end
end
