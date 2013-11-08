module Pacto
  module Stubs
    describe BuiltIn do
      let(:request) do
        double(
          :host => 'http://localhost',
          :method => method,
          :path => '/hello_world',
          :headers => {'Accept' => 'application/json'},
          :params => {'foo' => 'bar'}
        )
      end
      let(:request_with_placeholder) do
        double(
          :host => 'http://localhost',
          :method => method,
          :path => '/a/:id/c',
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
      let(:processor) { double('processor') }

      before(:each) do
        stubbed_request.stub(:to_return).with(
          :status => response.status,
          :headers => response.headers,
          :body => response.body.to_json,
        )
      end

      describe '#initialize' do
        it 'sets up a callback' do
          WebMock.should_receive(:after_request) do | arg, &block |
            expect(block.parameters).to have(2).items
          end

          described_class.new
        end
      end

      describe '#process_callbacks' do
        subject(:built_in) { described_class.new }
        let(:request_signature) { double('request_signature') }
        # let(:response) { double('response') }

        before(:each) do
          Pacto.configuration.callback.should_receive(:process)
          .with(anything, request_signature, response)
        end

        pending 'calls the registered callback'

        it 'calls generate when generate is enabled' do
          Pacto.generate!
          WebMockHelper.should_receive(:generate).with(request_signature, response)
          subject.process_callbacks request_signature, response
        end

        it 'calls validate when validate mode is enabled' do
          Pacto.validate!
          WebMockHelper.should_receive(:validate).with(request_signature, response)
          subject.process_callbacks request_signature, response
        end
      end

      describe '#stub_request!' do
        before(:each) do
          WebMock.should_receive(:stub_request) do | method, url |
            stubbed_request[:path] = url
            stubbed_request
          end
        end

        context 'not using strict_matchers' do
          context 'without a placeholder' do
            before do
              Pacto.configuration.strict_matchers = false
            end

            it 'stubs with a regex path_pattern' do
              described_class.new.stub_request! request, response
              expect(stubbed_request[:path]).to eq(/#{request.host}#{request.path}/)
            end
          end

          context 'with a placeholder do' do
            before do
              Pacto.configuration.strict_matchers = false
            end

            it 'stubs with a regex path_pattern including the placeholder' do
              described_class.new.stub_request! request_with_placeholder, response
              expected_regex = %r{#{request_with_placeholder.host}\/a\/[:\w]+\/c}
              # No luck comparing regexes for equality, but the string representation matches...
              expect(stubbed_request[:path].inspect).to eq(expected_regex.inspect)
            end
          end
        end

        context 'using strict_matchers' do
          before do
            Pacto.configuration.strict_matchers = true
          end

          it 'stubs with headers and no regex' do
            stubbed_request.should_receive(:with).with(
              :query => { 'foo' => 'bar' },
              :headers => { 'Accept' => 'application/json' }
            ).and_return(stubbed_request)
            described_class.new.stub_request! request, response
            expect(stubbed_request[:path]).to eq("#{request.host}#{request.path}")
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

              stubbed_request.stub(:with).and_return(stubbed_request)

              described_class.new.stub_request! request, response
            end
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

              stubbed_request.stub(:with).and_return(stubbed_request)

              described_class.new.stub_request! request, response
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

              stubbed_request.stub(:with).and_return(stubbed_request)

              described_class.new.stub_request! request, response
            end
          end

          context 'a GET request' do
            let(:method) { :get }

            it 'uses WebMock to stub the request' do
              stubbed_request.should_receive(:with).
                with(:headers => request.headers, :query => request.params).
                and_return(stubbed_request)
              described_class.new.stub_request! request, response
            end
          end

          context 'a POST request' do
            let(:method) { :post }

            it 'uses WebMock to stub the request' do
              stubbed_request.should_receive(:with).
                with(:headers => request.headers, :body => request.params).
                and_return(stubbed_request)
              described_class.new.stub_request! request, response
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
              stubbed_request.should_receive(:with).
                with(:query => request.params).
                and_return(stubbed_request)
              described_class.new.stub_request! request, response
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
              stubbed_request.should_receive(:with).
                with({}).
                and_return(stubbed_request)
              described_class.new.stub_request! request, response
            end
          end
        end
      end
    end
  end
end
