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
            "schema": {
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

    let(:partial_contract) do
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
          },

          "response": {
            "status": 200,
            "headers": {
              "Content-Type": "application/json"
            },
            "schema": {
              "description": "A simple response",
              "required": {},
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

    subject(:schema) { MetaSchema.new }

    describe 'when validating a contract against the master schema' do
      context 'with a valid contract structure' do
        it 'does not raise any exceptions' do
          expect do
            schema.validate(valid_contract)
          end.to_not raise_error
        end
      end

      context 'with an partial contract structure' do
        it 'raises InvalidContract exception' do
          expect do
            schema.validate(invalid_contract)
          end.to raise_error(InvalidContract)
        end
      end

      context 'with an invalid contract' do
        it 'raises InvalidContract exception' do
          expect do
            schema.validate(invalid_contract)
          end.to raise_error(InvalidContract)
        end
      end
    end
  end
end
