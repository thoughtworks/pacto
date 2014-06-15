module Pacto
  module Validators
    describe BodyValidator do
      class MyBodyValidator < BodyValidator
        class << self
          attr_writer :subschema

          def section_name
            'my_section'
          end

          def subschema(_contract)
            @subschema
          end
        end
      end

      subject(:validator)    { MyBodyValidator }
      let(:string_required)  { %w(#) }
      let(:contract)         { Fabricate(:contract, :file => 'file:///a.json') }
      let(:body)             { 'a simple string' }
      let(:fake_interaction) { double(:fake_interaction, body: body) }

      before(:each) do
        MyBodyValidator.subschema = schema
      end

      describe '#validate' do
        context 'when schema is not specified' do
          let(:schema) { nil }

          it 'gives no errors without validating body' do
            expect(JSON::Validator).not_to receive(:fully_validate)
            expect(validator.validate(contract, fake_interaction)).to be_empty
          end
        end

        context 'when the body is a string' do
          let(:schema) { { 'type' => 'string', 'required' => string_required } }

          it 'does not validate using JSON Schema' do
            validator.validate(contract, fake_interaction)
          end

          context 'if required' do
            it 'does not return an error when body is a string' do
              expect(validator.validate(contract, fake_interaction)).to be_empty
            end

            it 'returns an error when body is nil' do
              expect(fake_interaction).to receive(:body).and_return nil
              expect(validator.validate(contract, fake_interaction).size).to eq 1
            end
          end

          context 'if not required' do
            let(:string_required) { %w() }

            it 'does not return an error when body is a string' do
              expect(validator.validate(contract, fake_interaction)).to be_empty
            end

            it 'does not return an error when body is empty' do
              expect(fake_interaction).to receive(:body).and_return ''
              expect(validator.validate(contract, fake_interaction)).to be_empty
            end
          end

          context 'if contains pattern' do
            let(:schema) do
              { type: 'string', required: string_required, pattern: 'a.c' }
            end

            context 'body matches pattern' do
              let(:body) { 'abc' } # This matches the pattern /a.c/

              it 'does not return an error' do
                expect(validator.validate(contract, fake_interaction)).to be_empty
              end
            end

            context 'body does not match pattern' do
              let(:body) { 'acb' } # This does not matches the pattern /a.c/

              it 'returns an error' do
                expect(validator.validate(contract, fake_interaction).size).to eq 1
              end
            end
          end
        end

        context 'when the body is json' do
          let(:schema) { { type: 'object' } }

          context 'when body matches' do
            it 'does not return any errors' do
              expect(JSON::Validator).to receive(:fully_validate).and_return([])
              expect(validator.validate(contract, fake_interaction)).to be_empty
            end
          end

          context 'when body does not match' do
            it 'returns a list of errors' do
              errors = double 'some errors'
              expect(JSON::Validator).to receive(:fully_validate).and_return(errors)
              expect(validator.validate(contract, fake_interaction)).to eq(errors)
            end
          end
        end
      end
    end
  end
end
