module Pacto
  class RakeTask
    class GenerateTask
      include Pacto::CLI::Helpers

      def initialize(input_dir, output_dir, host)
        @input_dir, @output_dir, @host = input_dir, output_dir, host
        @generator = Pacto::Generator.contract_generator
      end

      def generate_contracts
        WebMock.allow_net_connect!
        show_initial_message

        self.failed_contracts = []
        each_contract(input_dir, &method(:generate_contract!))

        show_final_message
      end

      private

      attr_reader :generator, :input_dir, :output_dir, :host
      attr_accessor :failed_contracts

      def generate_contract!(contract_file)
        contract = generator.generate_from_partial_contract(contract_file, host)
        output_file = File.expand_path(File.basename(contract_file), output_dir)
        output_file = File.open(output_file, 'wb')
        output_file.write contract
        output_file.flush
        output_file.close
      rescue InvalidContract => e
        failed_contracts << contract_file
        puts Pacto::UI.colorize(e.message, :red)
      end

      def show_initial_message
        puts "Generating contracts from partial contracts in #{input_dir} and recording to #{output_dir}\n\n"
      end

      def show_final_message
        if failed_contracts.empty?
          puts Pacto::UI.colorize('Successfully generated all contracts', :green)
        else
          fail Pacto::UI.colorize("The following contracts could not be generated: #{failed_contracts.join ','}", :red)
        end
      end
    end
  end
end
