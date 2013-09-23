module Pacto
  module Stubs
    describe BuiltIn do
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
      let(:processor) { double('processor') }

      describe '#initialize' do
        it 'should setup a callback' do
          WebMock.should_receive(:after_request) do | arg, &block |
            block.parameters.size.should == 2
          end

          described_class.new
        end
      end

      describe '#stub!' do
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

        context 'when the response body is an object' do
          let(:body) do
            {'message' => 'foo'}
          end

          it 'should stub the response body with a json representation' do
            stubbed_request.should_receive(:to_return).with({
              :status => response.status,
              :headers => response.headers,
              :body => response.body.to_json
            })

            stubbed_request.stub(:with).and_return(stubbed_request)

            described_class.new.stub! request, response
          end
        end

        context 'when the response body is an array' do
          let(:body) do
            [1, 2, 3]
          end

          it 'should stub the response body with a json representation' do
            stubbed_request.should_receive(:to_return).with({
              :status => response.status,
              :headers => response.headers,
              :body => response.body.to_json
            })

            stubbed_request.stub(:with).and_return(stubbed_request)

            described_class.new.stub! request, response
          end
        end

        context 'when the response body is not an object or an array' do
          let(:body) { nil }

          it 'should stub the response body with the original body' do
            stubbed_request.should_receive(:to_return).with({
              :status => response.status,
              :headers => response.headers,
              :body => response.body
            })

            stubbed_request.stub(:with).and_return(stubbed_request)

            described_class.new.stub! request, response
          end
        end

        context 'a GET request' do
          let(:method) { :get }

          it 'should use WebMock to stub the request' do
            stubbed_request.should_receive(:with).
              with({:headers => request.headers, :query => request.params}).
              and_return(stubbed_request)
            described_class.new.stub! request, response
          end
        end

        context 'a POST request' do
          let(:method) { :post }

          it 'should use WebMock to stub the request' do
            stubbed_request.should_receive(:with).
              with({:headers => request.headers, :body => request.params}).
              and_return(stubbed_request)
            described_class.new.stub! request, response
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
            described_class.new.stub! request, response
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
            described_class.new.stub! request, response
          end
        end
      end
    end
  end
end
