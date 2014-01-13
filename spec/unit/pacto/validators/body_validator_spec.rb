module Pacto
  module Validators
    describe BodyValidator do
      subject(:validator) do
        class MyBodyValidator < BodyValidator
          def self.section_name
            'my_section'
          end
        end
        MyBodyValidator
      end
      let(:string_required) { true }
      let(:body_definition) do
        { 'type' => 'string', 'required' => string_required }
      end
      let(:body) { 'a simple string' }
      let(:fake_interaction) do
        double(:body => body)
      end
      describe '#validate' do
        context 'when body not specified' do
          it 'gives no errors without validating body' do
            JSON::Validator.should_not_receive(:fully_validate)
            expect(validator.validate(nil, fake_interaction)).to be_empty
          end
        end

        context 'when the body is a string' do
          it 'does not validate using JSON Schema' do
            # FIXME: This seems like a design flaw. We're partially reproducing json-schema behavior
            # instead of finding a way to use it.
            JSON::Validator.should_not_receive(:fully_validate)
            validator.validate(body_definition, fake_interaction)
          end

          context 'if required' do
            it 'does not return an error when body is a string' do
              expect(validator.validate(body_definition, fake_interaction)).to be_empty
            end

            it 'returns an error when body is nil' do
              expect(fake_interaction).to receive(:body).and_return nil
              expect(validator.validate(body_definition, fake_interaction).size).to eq 1
            end
          end

          context 'if not required' do
            let(:string_required) { false }

            it 'does not return an error when body is a string' do
              expect(validator.validate(body_definition, fake_interaction)).to be_empty
            end

            it 'does not return an error when body is nil' do
              expect(fake_interaction).to receive(:body).and_return nil
              expect(validator.validate(body_definition, fake_interaction)).to be_empty
            end
          end

          context 'if contains pattern' do
            let(:body_definition) do
              { 'type' => 'string', 'required' => string_required, 'pattern' => 'a.c' }
            end

            context 'body matches pattern' do
              let(:body) { 'cabcd' }

              it 'does not return an error' do
                expect(validator.validate(body_definition, fake_interaction)).to be_empty
              end
            end

            context 'body does not match pattern' do
              let(:body) { 'cabscd' }

              it 'returns an error' do
                expect(validator.validate(body_definition, fake_interaction).size).to eq 1
              end
            end
          end
        end
        context 'when the body is json' do
          let(:body_definition) do
            { 'type' => 'object' }
          end
          context 'when body matches' do
            it 'does not return any errors' do
              expect(JSON::Validator).to receive(:fully_validate).and_return([])
              expect(validator.validate(body_definition, fake_interaction)).to be_empty
            end
          end
          context 'when body does not match' do
            it 'returns a list of errors' do
              errors = double('some errors')
              expect(JSON::Validator).to receive(:fully_validate).and_return(errors)
              expect(validator.validate(body_definition, fake_interaction)).to eq(errors)
            end
          end
        end
      end
    end
  end
end
