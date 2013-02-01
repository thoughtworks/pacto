module Contracts
  describe ObjectAttribute do
    context 'sem atributos' do
      let(:properties) do
        {
          'type' => 'object',
          'properties' => {}
        }
      end

      it 'deve gerar objeto vazio' do
        described_class.new(properties).generate.should == {}
      end
    end

    context 'sem atributos obrigatórios' do
      let(:properties) do
        {
          'type' => 'object',
          'properties' => {
            'algum_atributo' => {
              'type' => 'string'
            }
          }
        }
      end

      it 'deve gerar objeto vazio' do
        described_class.new(properties).generate.should == {}
      end
    end

    context 'com atributo obrigatório' do
      let(:properties) do
        {
          'type' => 'object',
          'properties' => {
            'algum_atributo' => {
              'type' => 'string',
              'required' => 'true'
            }
          }
        }
      end
      let(:atributo) { stub('atributo') }

      it 'deve gerar objeto com um atributo' do
        AttributeFactory.should_receive(:create).
          with(properties['properties']['algum_atributo']).
          and_return(atributo)
        atributo.should_receive(:generate).and_return('foo')

        described_class.new(properties).generate.should == {'algum_atributo' => 'foo'}
      end
    end

    context 'com vários atributos obrigatórios' do
      let(:properties) do
        {
          'type' => 'object',
          'properties' => {
            'nome' => {
              'type' => 'string',
              'required' => 'true',
            },
            'email' => {
              'type' => 'integer',
              'required' => 'true',
            }
          }
        }
      end
      let(:nome) { stub('nome') }
      let(:email) { stub('email') }

      it 'deve gerar objeto com vários atributos' do
        AttributeFactory.should_receive(:create).
          with(properties['properties']['nome']).
          and_return(nome)
        nome.should_receive(:generate).and_return('nome falso')

        AttributeFactory.should_receive(:create).
          with(properties['properties']['email']).
          and_return(email)
        email.should_receive(:generate).and_return('email falso')

        described_class.new(properties).generate.should == {
          'nome' => 'nome falso',
          'email' => 'email falso'
        }
      end
    end
  end
end
