module Pacto
  class Utils
    class << self
      def all_contract_files_on *directories
        directories.unshift '**.json'
        directories.push Pacto.configuration.contracts_path
        directories.compact!
        Dir.glob(File.expand_path(*directories))
      end
    end
  end
end
