module Pacto
  module Core
    describe HTTPMiddleware do
      describe '#process' do
        xit 'calls the registered hook' do
          Pacto.configuration.hook.should_receive(:process)
            .with(anything, a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end

        xit 'calls generate when generate is enabled' do
          Pacto.generate!
          WebMockHelper.should_receive(:generate).with(a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end

        xit 'calls validate when validate mode is enabled' do
          Pacto.validate!
          WebMockHelper.should_receive(:validate).with(a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end
        xit 'validates a WebMock request/response pair' do
          described_class.validate @request_signature, @response
        end
      end
    end
  end
end