module Contracts
  describe StringAttribute do
    it 'deve ser um BasicAttribute' do
      described_class.new(nil).should be_kind_of(BasicAttribute)
    end

    context 'sem valor padrão' do
      it 'deve retornar o valor padrão' do
        properties = {
          'type' => 'string'
        }
        described_class.new(properties).generate.should == 'bar'
      end
    end
  end
end
