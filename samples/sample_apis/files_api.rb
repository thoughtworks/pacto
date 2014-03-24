# This example should illustrate
#   - Authentication
#   - Expect: 100-continue
#   - Binary data
#   - Content negotiation
#   - Etags
#   - Collections
module DummyServices
  class PartialRequestException < StandardError
    attr_reader :http_status, :msg
    def initialize(http_status, msg)
      @http_status = http_status
      @msg = msg
    end
  end

  class Files < Grape::API
    format :json
    content_type :binary, "application/octet-stream"
    content_type :pdf, "application/pdf"

    before do
      error!('Unauthorized', 401) unless env['HTTP_X_AUTH_TOKEN'] == '12345'

      if env['HTTP_EXPECT'] == '100-continue'
        # Can't use Content-Type because Grape tries to handle it, causing problems
        case env['CONTENT_TYPE']
        when 'application/pdf'
          raise DummyServices::PartialRequestException.new(100, 'Continue')
        when 'application/webm'
          raise DummyServices::PartialRequestException.new(415, 'Unsupported Media Type')
        else
          raise DummyServices::PartialRequestException.new(417, 'Expectation Failed')
        end
      end
    end

    rescue_from DummyServices::PartialRequestException do |e|
      Rack::Response.new([], e.http_status, {}).finish
    end

    namespace '/files'
      # curl localhost:9292/api/files/myfile.txt -H 'X-Auth-Token: 12345' -d @myfile.txt -vv
      put ':name' do
        params[:name]
      end
  end
end
