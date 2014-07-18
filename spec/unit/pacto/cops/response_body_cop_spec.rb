module Pacto
  module Cops
    describe ResponseBodyCop do
      subject(:cop) { ResponseBodyCop }

      describe "#subschema" do
        let(:response_schema) { double(:schema) }
        let(:contract) { Fabricate(:contract, response: { schema: response_schema }) }
        it "returns the response schema" do
          expect(subject.subschema(contract)).to eq response_schema
        end
      end

      describe "#body" do
        let(:request) { Fabricate(:pacto_request) }
        let(:response) { Fabricate(:pacto_response, body: 'response-body') }
        it "returns the response body" do
          expect(subject.body(request, response)).to eq 'response-body'
        end
      end

    end
  end
end
