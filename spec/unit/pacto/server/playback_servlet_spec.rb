# -*- encoding : utf-8 -*-
module Pacto
  module DummyServer
    describe PlaybackServlet do
      let(:request) { double }
      let(:response) { double('response', :status= => '', :[]= => '', :body= => '') }

      it 'alters response data with recorded status' do
        servlet = PlaybackServlet.new status: 200
        servlet.do_GET(request, response)
        expect(response).to have_received(:status=).with(200)
      end

      it 'alters reponse data with recorded headers' do
        servlet = PlaybackServlet.new headers: { 'Content-Type' => 'application/json' }
        servlet.do_GET(request, response)
        expect(response).to have_received(:[]=).with('Content-Type', 'application/json')
      end

      it 'alters reponse data with recorded ' do
        servlet = PlaybackServlet.new body: 'recorded'
        servlet.do_GET(request, response)
        expect(response).to have_received(:body=).with('recorded')
      end
    end
  end
end
