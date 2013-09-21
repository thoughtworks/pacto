require 'pacto'

unless String.respond_to?(:colors)
  class String
    def colorize(*args)
      self
    end
  end
end

module Pacto
  class RakeTask
    include Rake::DSL

    def initialize
      @exit_with_error = false
    end

    def install
      desc "Tasks for Pacto gem"
      namespace :pacto do
        validate_task
        meta_validate
      end
    end

    def validate_task
      desc "Validates all contracts in a given directory against a given host"
      task :validate, :host, :dir do |t, args|
        if args.to_a.size < 2
          fail "USAGE: rake pacto:validate[<host>, <contract_dir>]".colorize(:yellow)
        end

        validate_contracts(args[:host], args[:dir])
      end
    end

    def meta_validate
      desc "Validates a directory of contract definitions"
      task :meta_validate, :dir do |t, args|
        if args.to_a.size < 1
          fail "USAGE: rake pacto:meta_validate[<contract_dir>]".colorize(:yellow)
        end

        each_contract(args[:dir]) do |contract_file|
          puts "Validating #{contract_file}"
          fail unless Pacto.validate_contract contract_file
        end
      end
    end

    def validate_contracts(host, dir)
      WebMock.allow_net_connect!
      puts "Validating contracts in directory #{dir} against host #{host}\n\n"

      total_failed = 0
      each_contract(dir) do |contact_file|
        print "#{contract_file.split('/').last}:"
        contract = Pacto.build_from_file(contract_file, host)
        errors = contract.validate

        if errors.empty?
          puts " OK!".colorize(:green)
        else
          @exit_with_error = true
          total_failed += 1
          puts " FAILED!".colorize(:red)
          errors.each do |error|
            puts "\t* #{error}".colorize(:light_red)
          end
          puts ""
        end
      end

      if @exit_with_error
        fail "#{total_failed} of #{contracts.size} failed. Check output for detailed error messages.".colorize(:red)
      else
        puts "#{contracts.size} valid contract#{contracts.size > 1 ? 's' : nil}".colorize(:green)
      end
    end

    private

    def each_contract(dir)
      if File.file? dir
        yield dir
      else
        contracts = Dir[File.join(dir, '*{.json.erb,.json}')]
        fail "No contracts found in directory #{dir}".colorize(:yellow) if contracts.empty?

        contracts.sort.each do |contract_file|
          yield contract_file
        end
      end
    end
  end
end

Pacto::RakeTask.new.install
