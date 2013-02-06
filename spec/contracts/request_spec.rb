module Contracts
  describe Request do
    let(:host) { 'http://localhost' }
    let(:method) { 'GET' }
    let(:path) { '/hello_world' }
    let(:headers) { {'accept' => 'application/json'} }
    let(:params) { {'foo' => 'bar'} }

    let(:request) do
      described_class.new(host, {
        'method'  => method,
        'path'    => path,
        'headers' => headers,
        'params'  => params
      })
    end
    subject { request }

    its(:method) { should == :get }
    its(:path) { should == path }
    its(:headers) { should == headers }
    its(:params) { should == params }

    describe '#execute' do
      let(:connection) { double('connection') }
      let(:response) { double('response') }

      before do
        Faraday.should_receive(:new).with(host).and_return(connection)
      end

      context 'for a GET request' do
        it 'should make a GET request and return the response' do
          connection.should_receive(:get).with(path, params, headers).and_return(response)
          request.execute.should == response
        end
      end

      context 'for a POST request' do
        let(:method) { 'POST' }

        it 'should make a POST request and return the response' do
          connection.should_receive(:post).with(path, params, headers).and_return(response)
          request.execute.should == response
        end
      end
    end
  end
end
