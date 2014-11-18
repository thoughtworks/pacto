# -*- encoding : utf-8 -*-
RSpec.shared_examples 'a body cop' do | section_to_validate |
  subject(:cop) { described_class }
  let(:request_clause)  { Fabricate(:request_clause, schema: schema) }
  let(:response_clause) { Fabricate(:response_clause, schema: schema) }
  let(:contract)         do
    Fabricate(:contract, file: 'file:///a.json', request: request_clause, response: response_clause)
  end
  let(:string_required)  { %w(#) }
  let(:request)          { Fabricate(:pacto_request) }
  let(:response)         { Fabricate(:pacto_response) }
  let(:clause_to_validate) { contract.send section_to_validate }
  let(:object_to_validate) { send section_to_validate }

  describe '#validate' do
    context 'when schema is not specified' do
      let(:schema) { nil }

      it 'gives no errors without validating body' do
        expect(JSON::Validator).not_to receive(:fully_validate)
        expect(cop.investigate(request, response, contract)).to be_empty
      end
    end

    context 'when the expected body is a string' do
      let(:schema) { { 'type' => 'string', 'required' => string_required } }

      context 'if required' do
        it 'does not return an error when body is a string' do
          object_to_validate.body = 'asdf'
          expect(cop.investigate(request, response, contract)).to eq([])
        end

        it 'returns an error when body is nil' do
          object_to_validate.body = nil
          expect(cop.investigate(request, response, contract).size).to eq 1
        end
      end

      context 'if not required' do
        let(:string_required) { %w() }

        # Body can be empty but not nil if not required
        # Not sure if this is an issue or not
        skip 'does not return an error when body is a string' do
          expect(cop.investigate(request, response, contract)).to be_empty
        end

        it 'does not return an error when body is empty' do
          object_to_validate.body = ''
          expect(cop.investigate(request, response, contract)).to be_empty
        end
      end

      context 'if contains pattern' do
        let(:schema) do
          { type: 'string', required: string_required, pattern: 'a.c' }
        end

        context 'body matches pattern' do
          it 'does not return an error' do
            object_to_validate.body = 'abc'
            expect(cop.investigate(request, response, contract)).to be_empty
          end
        end

        context 'body does not match pattern' do
          it 'returns an error' do
            object_to_validate.body = 'acb' # This does not matches the pattern /a.c/
            expect(cop.investigate(request, response, contract).size).to eq 1
          end
        end
      end
    end

    context 'when the body is json' do
      let(:schema) { { type: 'object' } }

      context 'when body matches' do
        it 'does not return any errors' do
          expect(JSON::Validator).to receive(:fully_validate).and_return([])
          expect(cop.investigate(request, response, contract)).to be_empty
        end
      end

      context 'when body does not match' do
        it 'returns a list of errors' do
          errors = double 'some errors'
          expect(JSON::Validator).to receive(:fully_validate).and_return(errors)
          expect(cop.investigate(request, response, contract)).to eq(errors)
        end
      end
    end
  end
end

module Pacto
  module Cops
    describe RequestBodyCop do
      it_behaves_like 'a body cop', :request
    end

    describe ResponseBodyCop do
      it_behaves_like 'a body cop', :response
    end
  end
end
