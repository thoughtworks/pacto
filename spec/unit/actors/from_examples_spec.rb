# -*- encoding : utf-8 -*-
module Pacto
  module Actors
    describe FromExamples do

      let(:fallback) { double('fallback') }
      subject(:generator) { described_class.new fallback }

      context 'a contract without examples' do
        let(:contract) { Fabricate(:contract) }

        it_behaves_like 'an actor' do
          before(:each) do
            allow(fallback).to receive(:build_request).with(contract, {}).and_return(Fabricate(:pacto_request))
            allow(fallback).to receive(:build_response).with(contract, {}).and_return(Fabricate(:pacto_response))
          end
          let(:contract) { Fabricate(:contract) }
        end

        it 'uses the fallback actor' do
          expect(fallback).to receive(:build_request).with(contract, {})
          expect(fallback).to receive(:build_response).with(contract, {})
          generator.build_request contract
          generator.build_response contract
        end
      end

      context 'a contract with examples' do
        let(:contract) { Fabricate(:contract, example_count: 3) }
        let(:request) { generator.build_request contract }
        let(:response) { generator.build_response contract }

        it_behaves_like 'an actor' do
          let(:contract) { Fabricate(:contract, example_count: 3) }
        end

        context 'no example specified' do
          it 'uses the first example' do
            expect(request.body).to eq(contract.examples.values.first.request.body)
            expect(response.body).to eq(contract.examples.values.first.response.body)
          end
        end

        context 'example specified' do
          let(:name) { '1' }
          subject(:generator) { described_class.new fallback, Pacto::Actors::NamedExampleSelector }
          let(:request) { generator.build_request contract, example_name: name }
          let(:response) { generator.build_response contract, example_name: name }

          it 'uses the named example' do
            expect(request.body).to eq(contract.examples[name].request.body)
            expect(response.body).to eq(contract.examples[name].response.body)
          end
        end

        context 'with randomized behavior' do
          subject(:generator) { described_class.new fallback, Pacto::Actors::RandomExampleSelector }
          it 'returns a randomly selected example' do
            examples_requests = contract.examples.values.map(&:request)
            examples_responses = contract.examples.values.map(&:response)
            request_bodies = examples_requests.map(&:body)
            response_bodies = examples_responses.map(&:body)
            expect(request_bodies).to include request.body
            expect(response_bodies).to include response.body
          end
        end
      end
    end
  end
end
