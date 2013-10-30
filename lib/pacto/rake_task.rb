require 'pacto'

# FIXME: RakeTask is a huge class, refactor this please
# rubocop:disable ClassLength
module Pacto
  class RakeTask
    include Rake::DSL
    include ::Pacto::UI

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
          fail yellow('USAGE: rake pacto:validate[<host>, <contract_dir>]')
        end

        validate_contracts(args[:host], args[:dir])
      end
    end

    def generate_task
      desc 'Generates contracts from partial contracts'
      task :generate, :input_dir, :output_dir, :host do |t, args|
        if args.to_a.size < 3
          fail yellow('USAGE: rake pacto:generate[<request_contract_dir>, <output_dir>, <record_host>]')
        end

        generate_contracts(args[:input_dir], args[:output_dir], args[:host])
      end
    end

    # FIXME: meta_validate is a big method =(. Needs refactoring
    # rubocop:disable MethodLength
    def meta_validate
      desc 'Validates a directory of contract definitions'
      task :meta_validate, :dir do |t, args|
        if args.to_a.size < 1
          fail yellow('USAGE: rake pacto:meta_validate[<contract_dir>]')
        end

        each_contract(args[:dir]) do |contract_file|
          fail unless Pacto.validate_contract contract_file
        end
        puts 'All contracts successfully meta-validated'
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
          puts green(' OK!')
        else
          @exit_with_error = true
          total_failed += 1
          puts red(' FAILED!')
          errors.each do |error|
            puts red("\t* #{error}")
          end
          puts ''
        end
      end

      if @exit_with_error
        fail red("#{total_failed} of #{contracts.size} failed. Check output for detailed error messages.")
      else
        puts green("#{contracts.size} valid contract#{contracts.size > 1 ? 's' : nil}")
      end
    end
    # rubocop:enable MethodLength

    # FIXME: generate_contracts is a big method =(. Needs refactoring
    # rubocop:disable MethodLength
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
          puts red(e.message)
        end
      end

      if failed_contracts.empty?
        puts green('Successfully generated all contracts')
      else
        fail red("The following contracts could not be generated: #{failed_contracts.join ','}")
      end
    end
    # rubocop:enable MethodLength

    private

    def each_contract(dir)
      if File.file? dir
        yield dir
      else
        contracts = Dir[File.join(dir, '**/*{.json.erb,.json}')]
        fail "No contracts found in directory #{dir}".yellow if contracts.empty?

        contracts.sort.each do |contract_file|
          yield contract_file
        end
      end
    end
  end
end
# rubocop:enable ClassLength

Pacto::RakeTask.new.install
