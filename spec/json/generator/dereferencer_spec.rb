module JSON
  module Generator
    describe Dereferencer do
      describe '.dereference' do
        let(:schema) do
          {
            'type' => 'object',
            'properties' => {
              'referencer' => referencer
            },
            'definitions' => definitions
          }
        end

        let(:definitions) { {'referenced' => referenced} }

        let(:referencer) do
          {
            'type' => 'object',
            '$ref' => '#/definitions/referenced'
          }
        end

        let(:referenced) do
          {
            'properties' => {
              'message' => { 'type' => 'string' }
            }
          }
        end

        it 'should replace references with concrete definitions' do
          described_class.dereference(schema).should == {
            'type' => 'object',
            'properties' => {
              'referencer' => {
                'type' => 'object',
                'properties' => {
                  'message' => { 'type' => 'string' }
                }
              }
            }
          }
        end

        context 'when the schema does not have any reference', 'but has definitions' do
          let(:schema) { {'type' => 'object',  'properties' => {}, 'definitions' => {}} }

          it 'should return the original schema without the definitions' do
            described_class.dereference(schema).should == {'type' => 'object', 'properties' => {}}
          end
        end

        context 'when the root element does not have properties' do
          let(:schema) { {'type' => 'string'} }

          it 'should return the original schema' do
            described_class.dereference(schema).should == schema
          end
        end

        context 'when a referenced definition does not exist' do
          let(:definitions) { {} }

          it 'should raise a name error' do
            expect { described_class.dereference(schema) }.to raise_error NameError
          end
        end
      end
    end
  end
end
