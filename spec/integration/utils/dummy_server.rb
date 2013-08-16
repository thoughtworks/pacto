require 'webrick'

class Servlet < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server, json)
    super(server)
    @json = json
  end

  def do_GET(request, response)
    response.status = 200
    response['Content-Type'] = 'application/json'
    response.body = @json
  end
end

class DummyServer
  def initialize
    @server = WEBrick::HTTPServer.new :Port => 8000,
      :AccessLog => [],
      :Logger => WEBrick::Log::new("/dev/null", 7)
    @server.mount "/simple_contract.json", Servlet, '{"message": "Hello World!"}'
  end

  def start
    @pid = fork do
      trap 'INT' do @server.shutdown end
      @server.start
    end
  end

  def terminate
    Process.kill('INT', @pid)
  end
end
