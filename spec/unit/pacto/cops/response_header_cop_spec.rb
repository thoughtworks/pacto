module Pacto
  module Cops
    describe ResponseHeaderCop do
      subject(:cop) { described_class }
      let(:contract)         do
        response_clause = Fabricate(:response_clause, headers: expected_headers)
        Fabricate(:contract, response: response_clause)
      end
      let(:request)          { Fabricate(:pacto_request) }
      let(:response)         { Fabricate(:pacto_response, headers: actual_headers) }
      let(:expected_headers) do
        {
          'Content-Type' => 'application/json'
        }
      end
      describe '#investigate' do
        context 'when headers do not match' do
          let(:actual_headers) do
            { 'Content-Type' => 'text/html' }
          end
          it 'indicates the exact mismatches' do
            expect(cop.investigate(request, response, contract)).
              to eq ['Invalid response header Content-Type: expected "application/json" but received "text/html"']
          end
        end

        context 'when headers are missing' do
          let(:actual_headers) do
            {}
          end
          let(:expected_headers) do
            {
              'Content-Type' => 'application/json',
              'My-Cool-Header' => 'Whiskey Pie'
            }
          end
          it 'lists the missing headers' do
            expect(cop.investigate(request, response, contract)).
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
            let(:actual_headers) { { 'Content-Type' => 'application/json' } }
            it 'returns a header error when no Location header is sent' do
              expect(cop.investigate(request, response, contract)).to eq ['Missing expected response header: Location']
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
              response.headers = actual_headers
              expect(cop.investigate(request, response, contract)).to eq ["Invalid response header Location: expected URI #{actual_headers['Location']} to match URI Template #{expected_headers['Location']}"]
            end
          end

          context 'and the Location header matches pattern' do
            let(:actual_headers) do
              {
                'Content-Type' => 'application/json',
                'Location' => 'http://www.example.com/foo/bar'
              }
            end

            it 'investigates successfully' do
              expect(cop.investigate(request, response, contract)).to be_empty
            end
          end
        end

        context 'when headers are a subset of expected headers' do
          let(:actual_headers) { { 'Content-Type' => 'application/json' } }

          it 'does not return any errors' do
            expect(cop.investigate(request, response, contract)).to be_empty
          end
        end

        context 'when headers values match but keys have different case' do
          let(:actual_headers) { { 'content-type' => 'application/json' } }

          it 'does not return any errors' do
            expect(cop.investigate(request, response, contract)).to be_empty
          end
        end
      end
    end
  end
end
