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
      desc 'Tasks for Pacto gem'
      namespace :pacto do
        validate_task
        generate_task
        meta_validate
      end
    end

    def validate_task
      desc 'Validates all contracts in a given directory against a given host'
      task :validate, :host, :dir do |t, args|
        if args.to_a.size < 2
          fail 'USAGE: rake pacto:validate[<host>, <contract_dir>]'.colorize(:yellow)
        end

        validate_contracts(args[:host], args[:dir])
      end
    end

    def generate_task
      desc 'Generates contracts from partial contracts'
      task :generate, :input_dir, :output_dir, :host do |t, args|
        if args.to_a.size < 3
          fail 'USAGE: rake pacto:generate[<request_contract_dir>, <output_dir>, <record_host>]'.colorize(:yellow)
        end

        generate_contracts(args[:input_dir], args[:output_dir], args[:host])
      end
    end

    def meta_validate
      desc 'Validates a directory of contract definitions'
      task :meta_validate, :dir do |t, args|
        if args.to_a.size < 1
          fail 'USAGE: rake pacto:meta_validate[<contract_dir>]'.colorize(:yellow)
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
          puts ' OK!'.colorize(:green)
        else
          @exit_with_error = true
          total_failed += 1
          puts ' FAILED!'.colorize(:red)
          errors.each do |error|
            puts "\t* #{error}".colorize(:light_red)
          end
          puts ''
        end
      end

      if @exit_with_error
        fail "#{total_failed} of #{contracts.size} failed. Check output for detailed error messages.".colorize(:red)
      else
        puts "#{contracts.size} valid contract#{contracts.size > 1 ? 's' : nil}".colorize(:green)
      end
    end

    def generate_contracts(input_dir, output_dir, host)
      WebMock.allow_net_connect!
      generator = Pacto::Generator.new
      puts "Generating contracts from partial contracts in #{input_dir} and recording to #{output_dir}\n\n"

      failed_contracts = []
      each_contract(input_dir) do |contract_file|
        begin
          contract = generator.generate(contract_file, host)
          output_file = File.expand_path(File.basename(contract_file), output_dir)
          output_file = File.open(output_file, 'wb')
          output_file.write contract
          output_file.flush
          output_file.close
        rescue InvalidContract => e
          failed_contracts << contract_file
          puts e.message.colorize(:red)
        end
      end

      if failed_contracts.empty?
        puts 'Successfully generated all contracts'.colorize(:green)
      else
        fail "The following contracts could not be generated: #{failed_contracts.join ','}".colorize(:red)
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
