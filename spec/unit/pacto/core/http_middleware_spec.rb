# -*- encoding : utf-8 -*-
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

        pending 'logs rescues and logs failures'
        pending 'calls the HTTP middleware'
        pending 'calls the registered hook'
        pending 'calls generate when generate is enabled'
        pending 'calls validate when validate mode is enabled'
        pending 'validates a WebMock request/response pair'
      end
    end
  end
end
