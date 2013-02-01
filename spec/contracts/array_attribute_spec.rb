module Contracts
  describe ArrayAttribute do
    context 'com minItems' do
      it 'deve retornar um array com dois objetos do tipo esperado' do
        stubbed_item = stub('item', :generate => 'foo')
        AttributeFactory.should_receive(:create).twice.
          with('type' => 'dummy_type').
          and_return(stubbed_item)

        properties = {
          'type' => 'array',
          'minItems' => 2,
          'items' => {
            'type' => 'dummy_type'
          }
        }
        described_class.new(properties).generate.should ==
          [stubbed_item.generate, stubbed_item.generate]
      end
    end

    context 'sem minItems' do
      it 'deve retornar um array vazio' do
        properties = {
          'type' => 'array',
          'items' => {
            'type' => 'dummy_type'
          }
        }
        described_class.new(properties).generate.should == []
      end
    end
  end
end
