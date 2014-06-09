module Pacto
  describe Contract do
    let(:request_clause) do
      Pacto::RequestClause.new(
        method: 'GET',
        host: 'http://example.com',
        schema:  {
          :type => 'object',
          :required => true # , :properties => double('body definition properties')
        }
      )
    end
    let(:response_clause) do
      Pacto::ResponseClause.new(:status => 200)
    end
    let(:adapter) { double 'provider' }
    let(:file) { 'contract.json' }
    let(:request_pattern_provider) { double(for: nil) }
    let(:consumer_driver) { double }
    let(:provider_actor) { double }

    subject(:contract) do
      Contract.new(
        request: request_clause,
        response: response_clause,
        file: file,
        name: 'sample',
        request_pattern_provider: request_pattern_provider
      )
    end

    before do
      Pacto.configuration.adapter = adapter
      allow(consumer_driver).to receive(:respond_to?).with(:execute).and_return true
      allow(provider_actor).to receive(:respond_to?).with(:build_response).and_return true
      Pacto.configuration.default_consumer.driver = consumer_driver
      Pacto.configuration.default_provider.actor = provider_actor
    end

    describe '#stub_contract!' do
      it 'register a stub for the contract' do
        adapter.should_receive(:stub_request!).with(contract)
        contract.stub_contract!
      end
    end

    context 'validations' do
      let(:request) { Pacto.configuration.default_consumer.build_request contract }
      let(:fake_response) { double('fake response') }
      let(:validation_result) { double 'validation result' }
      let(:validation) { Validation.new request, fake_response, contract, validation_result }

      before do
        allow(Pacto::ContractValidator).to receive(:validate_contract).with(an_instance_of(Pacto::PactoRequest), fake_response, contract, {}).and_return validation
      end

      describe '#validate_response' do
        it 'returns the result of the validation' do
          expect(Pacto::ContractValidator).to receive(:validate_contract).with(an_instance_of(Pacto::PactoRequest), fake_response, contract, {})
          expect(contract.validate_response request, fake_response).to eq validation
        end

        it 'does not generate another response' do
          consumer_driver.should_not_receive :execute
          contract.validate_response request, fake_response
        end
      end

      describe '#validate_provider' do
        before do
          allow(consumer_driver).to receive(:execute).with(an_instance_of(Pacto::PactoRequest)).and_return fake_response
        end

        it 'generates the response' do
          expect(consumer_driver).to receive(:execute).with(an_instance_of(Pacto::PactoRequest))
          contract.validate_provider
        end

        it 'returns the result of the validating the generated response' do
          expect(Pacto::ContractValidator).to receive(:validate_contract).with(an_instance_of(Pacto::PactoRequest), fake_response, contract, {})
          expect(contract.validate_provider).to eq validation
        end
      end
    end

    describe '#matches?' do
      let(:request_pattern) { double(matches?: true) }
      let(:request_signature)  { double }

      it 'delegates to the request pattern' do
        expect(request_pattern_provider).to receive(:for).and_return(request_pattern)
        expect(request_pattern).to receive(:matches?).with(request_signature)

        contract.matches?(request_signature)
      end
    end
  end
end
