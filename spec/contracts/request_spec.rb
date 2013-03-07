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
      let(:adapted_response) { double('adapted response') }

      context 'for a GET request' do
        it 'should make a GET request and return the response' do
          HTTParty.should_receive(:get).
            with(host + path, {:query => params, :headers => headers}).
            and_return(response)
          ResponseAdapter.should_receive(:new).with(response).and_return(adapted_response)
          request.execute.should == adapted_response
        end
      end

      context 'for a POST request' do
        let(:method) { 'POST' }

        it 'should make a POST request and return the response' do
          HTTParty.should_receive(:post).
            with(host + path, {:body => params, :headers => headers}).
            and_return(response)
          ResponseAdapter.should_receive(:new).with(response).and_return(adapted_response)
          request.execute.should == adapted_response
        end
      end
    end

    describe "#absolute_uri" do
      it "should be equal to the host followed by the path" do
        request.absolute_uri.should == "http://localhost/hello_world"
      end
    end

    describe "#full_uri" do
      context "when the query (params) exists" do
        it "should be equal to the host followed by the path and the query" do
          request.full_uri.should == "http://localhost/hello_world?foo=bar"
        end
      end

      context "when the query (params) does not exists" do
        let(:params) { {} }
        it "should be equal to the host followed by the path" do
          request.full_uri.should == "http://localhost/hello_world"
        end
      end
    end
  end
end
