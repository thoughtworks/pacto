require 'pathname'
module Pacto
  class ContractFiles
    def self.for(path)
      full_path = Pathname.new(path).realpath

      if  full_path.directory?
        Dir.glob("#{full_path}/**/*.json").map do |f|
          Pathname.new(f)
        end
      else
        [full_path]
      end
    end
  end
end
