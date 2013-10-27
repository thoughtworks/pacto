module Pacto
  describe MetaSchema do
    let(:valid_contract) do
      <<-EOF
        {
          "request": {
            "method": "GET",
            "path": "/hello_world",
            "headers": {
              "Accept": "application/json"
            },
            "params": {}
          },

          "response": {
            "status": 200,
            "headers": {
              "Content-Type": "application/json"
            },
            "body": {
              "description": "A simple response",
              "type": "object",
              "properties": {
                "message": {
                  "type": "string"
                }
              }
            }
          }
        }
      EOF
    end

    let(:invalid_contract) do
      <<-EOF
        {
          "request": {
            "method": "GET",
            "path": "/hello_world",
            "headers": {
              "Accept": "application/json"
            },
            "params": {}
          }

        }
      EOF
    end

    subject(:schema) { MetaSchema.new }

    describe 'when validating a contract against the master schema' do
      context 'with a valid contract structure' do
        it 'does not raise any exceptions' do
          expect do
            schema.validate(valid_contract)
          end.to_not raise_error(Exception)
        end
      end

      context 'with an invalid contract structure' do
        it 'raises InvalidContract exception' do
          expect do
            schema.validate(invalid_contract)
          end.to raise_error(InvalidContract)
        end
      end
    end
  end
end
