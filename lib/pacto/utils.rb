module Pacto
  class Utils
    class << self
      def all_contract_files_on(subdirectory)
        dirs = [Pacto.configuration.contracts_path, subdirectory].compact
        Dir.glob File.expand_path('**/*.json', File.join(dirs))
      end
    end
  end
end
