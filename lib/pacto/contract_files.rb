require 'pathname'
module Pacto
  class ContractFiles
    def self.for(path)
      full_path = Pathname.new(path).realpath

      if  full_path.directory?
        Dir.entries(full_path).grep(/\.json/).map do |f|
          Pathname.new(File.join(full_path, f))
        end
      else
        [full_path]
      end
    end
  end
end
