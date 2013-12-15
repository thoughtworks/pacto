module Pacto
  module Validators
    describe ResponseBodyValidator do
      subject(:validator) { described_class }
      let(:string_required) { true }
      let(:body_definition) do
        { 'type' => 'string', 'required' => string_required }
      end
      let(:response_body) { 'a simple string' }
      let(:fake_response) do
        double(
          :body => response_body
        )
      end
      describe '#validate' do
        context 'when body not specified' do
          it 'gives no errors without validating body' do
            JSON::Validator.should_not_receive(:fully_validate)
            expect(validator.validate(nil, fake_response)).to be_empty
          end
        end

        context 'when the body is a string' do
          it 'does not validate using JSON Schema' do
            # FIXME: This seems like a design flaw. We're partially reproducing json-schema behavior
            # instead of finding a way to use it.
            JSON::Validator.should_not_receive(:fully_validate)
            validator.validate(body_definition, fake_response)
          end

          context 'if required' do
            it 'does not return an error when body is a string' do
              expect(validator.validate(body_definition, fake_response)).to be_empty
            end

            it 'returns an error when body is nil' do
              expect(fake_response).to receive(:body).and_return nil
              expect(validator.validate(body_definition, fake_response).size).to eq 1
            end
          end

          context 'if not required' do
            let(:string_required) { false }

            it 'does not return an error when body is a string' do
              expect(validator.validate(body_definition, fake_response)).to be_empty
            end

            it 'does not return an error when body is nil' do
              expect(fake_response).to receive(:body).and_return nil
              expect(validator.validate(body_definition, fake_response)).to be_empty
            end
          end

          context 'if contains pattern' do
            let(:body_definition) do
              { 'type' => 'string', 'required' => string_required, 'pattern' => 'a.c' }
            end

            context 'body matches pattern' do
              let(:response_body) { 'cabcd' }

              it 'does not return an error' do
                expect(validator.validate(body_definition, fake_response)).to be_empty
              end
            end

            context 'body does not match pattern' do
              let(:response_body) { 'cabscd' }

              it 'returns an error' do
                expect(validator.validate(body_definition, fake_response).size).to eq 1
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
              expect(validator.validate(body_definition, fake_response)).to be_empty
            end
          end
          context 'when body does not match' do
            it 'returns a list of errors' do
              errors = double('some errors')
              expect(JSON::Validator).to receive(:fully_validate).and_return(errors)
              expect(validator.validate(body_definition, fake_response)).to eq(errors)
            end
          end
        end
      end
    end
  end
end
