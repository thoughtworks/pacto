module Pacto
  module Stubs
    class WebMockHelper
      class << self
        def validate(request_signature, response)
          pacto_response = webmock_to_pacto_response(response)
          contract = Pacto.contract_for(request_signature)
          validation = Validation.new request_signature, pacto_response, contract
          Pacto::ValidationRegistry.instance.register_validation validation
        end

        def generate(request_signature, response)
          logger.debug("Generating Contract for #{request_signature}, #{response}")
          uri = URI(request_signature.uri)
          basename = File.basename(uri.path, '.json') + '.json'
          pacto_request = webmock_to_pacto_request(request_signature)
          pacto_response = webmock_to_pacto_response(response)
          # contract_file = File.expand_path(Pacto.configuration.contracts_path, File.dirname(uri.path), basename)
          contract_file = File.join(Pacto.configuration.contracts_path, uri.host, File.dirname(uri.path), basename)

          unless File.exists? contract_file
            generator = Pacto::Generator.new
            FileUtils.mkdir_p(File.dirname contract_file)
            begin
              File.write(contract_file, generator.save('vcr', pacto_request, pacto_response))
              logger.debug("Generating #{contract_file}")
            rescue => e
              logger.error("Error while generating Contract: #{e.inspect}")
            end
          end
        end

        private

        def logger
          @logger ||= Logger.instance
        end

        def webmock_to_pacto_request webmock_request
          uri = URI(webmock_request.uri)
          definition = {
            'method' => webmock_request.method,
            'path' => uri.path,
            # How do we get params?
            'params' => {},
            'headers' => webmock_request.headers || {}
          }
          Pacto::Request.new uri.host, definition
        end

        def webmock_to_pacto_response webmock_response
          status, _description = webmock_response.status
          OpenStruct.new(
            'status' => status,
            'headers' => webmock_response.headers || {},
            'body' => webmock_response.body
          )
        end
      end
    end
  end
end
