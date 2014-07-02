module Pacto
  module Validators
    describe BodyValidator do
      subject(:validator)    { ResponseBodyValidator }
      let(:string_required)  { %w(#) }
      let(:contract)         do
        response_clause = Fabricate(:response_clause, schema: schema)
        Fabricate(:contract, file: 'file:///a.json', response: response_clause)
      end
      let(:body)             { 'a simple string' }
      let(:fake_interaction) { double(:fake_interaction, body: body) }
      let(:request)          { Fabricate(:pacto_request) }
      let(:response)         { Fabricate(:pacto_response) }

      describe '#validate' do
        context 'when schema is not specified' do
          let(:schema) { nil }

          it 'gives no errors without validating body' do
            expect(JSON::Validator).not_to receive(:fully_validate)
            expect(validator.validate(request, response, contract)).to be_empty
          end
        end

        context 'when the body is a string' do
          let(:schema) { { 'type' => 'string', 'required' => string_required } }

          it 'does not validate using JSON Schema' do
            validator.validate(request, response, contract)
          end

          context 'if required' do
            it 'does not return an error when body is a string' do
              response.body = 'asdf'
              expect(validator.validate(request, response, contract)).to be_empty
            end

            it 'returns an error when body is nil' do
              response.body = nil
              expect(validator.validate(request, response, contract).size).to eq 1
            end
          end

          context 'if not required' do
            let(:string_required) { %w() }

            it 'does not return an error when body is a string' do
              expect(validator.validate(request, response, contract)).to be_empty
            end

            it 'does not return an error when body is empty' do
              response.body = ''
              expect(validator.validate(request, response, contract)).to be_empty
            end
          end

          context 'if contains pattern' do
            let(:contract) do
              schema = { type: 'string', required: string_required, pattern: 'a.c' }
              response_clause = Fabricate(:response_clause, schema: schema)
              Fabricate(:contract, response: response_clause)
            end

            context 'body matches pattern' do
              it 'does not return an error' do
                response.body = 'abc'
                expect(validator.validate(request, response, contract)).to be_empty
              end
            end

            context 'body does not match pattern' do
              it 'returns an error' do
                response.body = 'acb' # This does not matches the pattern /a.c/
                expect(validator.validate(request, response, contract).size).to eq 1
              end
            end
          end
        end

        context 'when the body is json' do
          let(:schema) { { type: 'object' } }

          context 'when body matches' do
            it 'does not return any errors' do
              expect(JSON::Validator).to receive(:fully_validate).and_return([])
              expect(validator.validate(request, response, contract)).to be_empty
            end
          end

          context 'when body does not match' do
            it 'returns a list of errors' do
              errors = double 'some errors'
              expect(JSON::Validator).to receive(:fully_validate).and_return(errors)
              expect(validator.validate(request, response, contract)).to eq(errors)
            end
          end
        end
      end
    end
  end
end
