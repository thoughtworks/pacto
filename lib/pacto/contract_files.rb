require 'pathname'
module Pacto
  class ContractFiles
    def self.for(path)
      full_path = Pathname.new(path).realpath

      if  full_path.directory?
        all_json_files = "#{full_path}/**/*.json"
        Dir.glob(all_json_files).map do |f|
          Pathname.new(f)
        end
      else
        [full_path]
      end
    end
  end
end
