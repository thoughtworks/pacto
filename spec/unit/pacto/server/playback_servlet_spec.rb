module Pacto::Server 
  describe PlaybackServlet do
    let(:request) { double }
    let(:response) { double(:response)}
    let(:recorded_message) { "leave the message after the bip"}
  
    it "should alter response data with recorded information" do
      servlet = PlaybackServlet.new recorded_message
      expect(response).to receive(:status=).with(200)
      expect(response).to receive(:[]=).with("Content-Type", "application/json") 
      expect(response).to receive(:body=).with(recorded_message)  
      servlet.do_GET(request, response)
    end
  end
end