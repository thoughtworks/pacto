module Pacto
  module Cops
    describe RequestBodyCop do
      subject(:cop) { RequestBodyCop }

      describe "#subschema" do
        let(:request_schema) { double(:schema) }
        let(:contract) { Fabricate(:contract, request: { schema: request_schema }) }
        it "returns the response schema" do
          expect(subject.subschema(contract)).to eq request_schema
        end
      end

      describe "#body" do
        let(:request) { Fabricate(:pacto_request, body: 'request-body') }
        let(:response) { Fabricate(:pacto_response) }
        it "returns the request body" do
          expect(subject.body(request, response)).to eq 'request-body'
        end
      end

    end
  end
end
