# -*- encoding : utf-8 -*-
module Pacto
  module Formats
    module Legacy
      describe ContractBuilder do
        let(:data) { subject.build_hash }
        describe '#name' do
          it 'sets the contract name' do
            subject.name = 'foo'
            expect(data).to include(name: 'foo')
          end
        end

        describe '#add_example' do
          let(:examples) { subject.build_hash[:examples] }
          it 'adds named examples to the contract' do
            subject.add_example 'foo', Fabricate(:pacto_request), Fabricate(:pacto_response)
            subject.add_example 'bar', Fabricate(:pacto_request), Fabricate(:pacto_response)
            expect(examples).to be_a(Hash)
            expect(examples.keys).to include('foo', 'bar')
            expect(examples['foo'][:response]).to include(status: 200)
            expect(data)
          end
        end

        context 'without examples' do
          describe '#infer_schemas' do
            it 'does not add schemas' do
              subject.name = 'test'
              subject.infer_schemas
              expect(data[:request][:schema]).to be_nil
              expect(data[:response][:schema]).to be_nil
            end
          end
        end

        context 'with examples' do
          before(:each) do
            subject.add_example 'success', Fabricate(:pacto_request), Fabricate(:pacto_response)
            subject.add_example 'not found', Fabricate(:pacto_request), Fabricate(:pacto_response)
          end

          describe '#without_examples' do
            it 'stops the builder from including examples in the final data' do
              expect(subject.build_hash.keys).to include(:examples)
              expect(subject.without_examples.build_hash.keys).to_not include(:examples)
            end
          end

          describe '#infer_schemas' do
            it 'adds schemas' do
              subject.name = 'test'
              subject.infer_schemas
              contract = subject.build
              expect(contract.request.schema).to_not be_nil
              expect(contract.request.schema).to_not be_nil
            end
          end
        end

        context 'generating from interactions' do
          let(:request) { Fabricate(:pacto_request) }
          let(:response) { Fabricate(:pacto_response) }
          let(:data) { subject.generate_response(request, response).build_hash }
          let(:contract) { subject.generate_contract(request, response).build }

          describe '#generate_response' do
            it 'sets the response status' do
              expect(data[:response]).to include(
                                                   status: 200
                                                 )
            end

            it 'sets response headers' do
              expect(data[:response][:headers]).to be_a(Hash)
            end
          end

          describe '#infer_schemas' do
            it 'sets the schemas based on the examples' do
              expect(contract.request.schema).to_not be_nil
              expect(contract.request.schema).to_not be_nil
            end
          end
        end

        skip '#add_request_header'
        skip '#add_response_header'
        skip '#filter'
      end
    end
  end
end
