module Pacto
  module Validators
    describe ResponseHeaderValidator do
      subject(:validator) { described_class }
      let(:expected_headers) do
        {
          'Content-Type' => 'application/json'
        }
      end
      describe '#validate' do
        context 'when headers do not match' do
          let(:actual_headers) { {'Content-Type' => 'text/html'} }

          it 'indicates the exact mismatches' do
            expect(validator.validate(expected_headers, actual_headers)).
              to eq ['Invalid response header Content-Type: expected "application/json" but received "text/html"']
          end
        end

        context 'when headers are missing' do
          let(:actual_headers) { {} }
          let(:expected_headers) do
            {
              'Content-Type' => 'application/json',
              'My-Cool-Header' => 'Whiskey Pie'
            }
          end
          it 'lists the missing headers' do
            expect(validator.validate(expected_headers, actual_headers)).
              to eq [
                'Missing expected response header: Content-Type',
                'Missing expected response header: My-Cool-Header'
              ]
          end
        end

        context 'when Location Header is expected' do
          before(:each) do
            expected_headers.merge!('Location' => 'http://www.example.com/{foo}/bar')
          end

          context 'and no Location header is sent' do
            let(:actual_headers) { {'Content-Type' => 'application/json'} }
            it 'returns a header error when no Location header is sent' do
              expect(validator.validate(expected_headers, actual_headers)).to eq ['Missing expected response header: Location']
            end
          end

          context 'but the Location header does not matches the pattern' do
            let(:actual_headers) do
              {
                'Content-Type' => 'application/json',
                'Location' => 'http://www.example.com/foo/bar/baz'
              }
            end

            it 'returns a validation error' do
              expect(validator.validate(expected_headers, actual_headers)).to eq ["Invalid response header Location: expected URI #{actual_headers['Location']} to match URI Template #{expected_headers['Location']}"]
            end
          end

          context 'and the Location header matches pattern' do
            let(:actual_headers) do
              {
                'Content-Type' => 'application/json',
                'Location' => 'http://www.example.com/foo/bar'
              }
            end

            it 'validates successfully' do
              expect(validator.validate(expected_headers, actual_headers)).to be_empty
            end
          end
        end

        context 'when headers are a subset of expected headers' do
          let(:actual_headers) { {'Content-Type' => 'application/json'} }

          it 'does not return any errors' do
            expect(validator.validate(expected_headers, actual_headers)).to be_empty
          end
        end

        context 'when headers values match but keys have different case' do
          let(:actual_headers) { {'content-type' => 'application/json'} }

          it 'does not return any errors' do
            expect(validator.validate(expected_headers, actual_headers)).to be_empty
          end
        end
      end
    end
  end
end
