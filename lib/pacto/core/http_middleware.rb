module Pacto
  module Core
    class HTTPMiddleware
      include Logger

      def process(request, response)
        generate(request, response) if Pacto.generating?

        contracts = Pacto.contracts_for request
        Pacto.configuration.hook.process contracts, request, response

        validate(request, response) if Pacto.validating?
      end


      # These will be exacted to other classes soon

      def validate(request_signature, pacto_response)
        contract = Pacto.contracts_for(request_signature).first
        validation = Validation.new request_signature, pacto_response, contract
        Pacto::ValidationRegistry.instance.register_validation validation
      end

      def generate(request_signature, response)
        logger.debug("Generating Contract for #{request_signature}, #{response}")
        begin
          contract_file = load_contract_file(request_signature)

          unless File.exists? contract_file
            generate_contract(request_signature, response, contract_file)
          end
        rescue => e
          logger.error("Error while generating Contract #{contract_file}: #{e.message}")
          logger.error("Backtrace: #{e.backtrace}")
        end
      end

      private

      def generate_contract(pacto_request, pacto_response, contract_file)
        uri = URI(pacto_request.uri)
        generator = Pacto::Generator.new
        FileUtils.mkdir_p(File.dirname contract_file)
        File.write(contract_file, generator.save(uri, pacto_request, pacto_response))
        logger.debug("Generating #{contract_file}")

        Pacto.load_contract contract_file, uri.host
      end

      def load_contract_file(request_signature)
        uri = URI(request_signature.uri)
        path = uri.path
        basename = File.basename(path, '.json') + '.json'
        File.join(Pacto.configuration.contracts_path, uri.host, File.dirname(path), basename)
      end

    end
  end
end