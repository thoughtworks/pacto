module Pacto
  module Core
    describe HTTPMiddleware do
      subject(:middleware) { Pacto::Core::HTTPMiddleware.new }
      let(:request) { double }
      let(:response) { double }

      class FailingObserver
        def raise_error(_pacto_request, _pacto_response)
          fail InvalidContract, ['The contract was missing things', 'and stuff']
        end
      end

      describe '#process' do
        it 'calls registered HTTP observers' do
          observer1, observer2 = double, double
          expect(observer1).to receive(:respond_to?).with(:do_something).and_return true
          expect(observer2).to receive(:respond_to?).with(:do_something_else).and_return true
          middleware.add_observer(observer1, :do_something)
          middleware.add_observer(observer2, :do_something_else)
          expect(observer1).to receive(:do_something).with(request, response)
          expect(observer2).to receive(:do_something_else).with(request, response)
          middleware.process request, response
        end

        it 'logs rescues and logs failures' do
          middleware.add_observer FailingObserver.new, :raise_error
          middleware.process request, response
          # FIXME: Add this assertion after switching to the Logging gem.
          # expect(@log_output).to include 'InvalidContract'
        end

        it 'calls the HTTP middleware' do
        end

        xit 'calls the registered hook' do
          expect(Pacto.configuration.hook).to receive(:process)
            .with(anything, a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end

        xit 'calls generate when generate is enabled' do
          Pacto.generate!
          expect(WebMockHelper).to receive(:generate).with(a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end

        xit 'calls validate when validate mode is enabled' do
          Pacto.validate!
          expect(WebMockHelper).to receive(:validate).with(a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end
        xit 'validates a WebMock request/response pair' do
          described_class.validate request_signature, response
        end
      end
    end
  end
end
