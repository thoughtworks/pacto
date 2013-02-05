module Contracts
  describe Request do
    subject do
      described_class.new('http://localhost', {
        'method'  => 'GET',
        'path'    => '/hello_world',
        'headers' => {'accept' => 'application/json'},
        'params'  => {'foo' => 'bar'}
      })
    end

    its(:method) { should == :get }
    its(:path) { should == '/hello_world' }
    its(:headers) { should == {'accept' => 'application/json'} }
    its(:params) { should == {'foo' => 'bar'} }
  end
end
