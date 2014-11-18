module Pacto
  module CLI
    module Helpers
      def each_contract(*contracts)
        [*contracts].each do |contract|
          if File.file? contract
            yield contract
          else # Should we assume it's a dir, or also support glob patterns?
            contracts = Dir[File.join(contract, '**/*{.json.erb,.json}')]
            fail Pacto::UI.colorize("No contracts found in directory #{contract}", :yellow) if contracts.empty?

            contracts.sort.each do |contract_file|
              yield contract_file
            end
          end
        end
      end
    end
  end
end
