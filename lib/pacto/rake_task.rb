# -*- encoding : utf-8 -*-
require 'pacto'
require 'thor'
require 'pacto/cli'
require 'pacto/cli/helpers'

# FIXME: RakeTask is a huge class, refactor this please
# rubocop:disable ClassLength
module Pacto
  class RakeTask
    extend Forwardable
    include Thor::Actions
    include Rake::DSL
    include Pacto::CLI::Helpers

    def initialize
      @exit_with_error = false
      @cli = Pacto::CLI::Main.new
    end

    def run(task, args, opts = {})
      Pacto::CLI::Main.new([], opts).public_send(task, *args)
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
      task :validate, :host, :dir do |_t, args|
        opts = args.to_hash
        dir = opts.delete :dir
        run(:validate, dir, opts)
      end
    end

    def generate_task
      desc 'Generates contracts from partial contracts'
      task :generate, :input_dir, :output_dir, :host do |_t, args|
        if args.to_a.size < 3
          fail Pacto::UI.colorize('USAGE: rake pacto:generate[<request_contract_dir>, <output_dir>, <record_host>]', :yellow)
        end

        generate_contracts(args[:input_dir], args[:output_dir], args[:host])
      end
    end

    def meta_validate
      desc 'Validates a directory of contract definitions'
      task :meta_validate, :dir do |_t, args|
        run(:meta_validate, *args)
      end
    end

    # rubocop:enable MethodLength

    # FIXME: generate_contracts is a big method =(. Needs refactoring
    # rubocop:disable MethodLength
    def generate_contracts(input_dir, output_dir, host)
      WebMock.allow_net_connect!
      generator = Pacto::Generator.contract_generator
      puts "Generating contracts from partial contracts in #{input_dir} and recording to #{output_dir}\n\n"

      failed_contracts = []
      each_contract(input_dir) do |contract_file|
        begin
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
      end

      if failed_contracts.empty?
        puts Pacto::UI.colorize('Successfully generated all contracts', :green)
      else
        fail Pacto::UI.colorize("The following contracts could not be generated: #{failed_contracts.join ','}", :red)
      end
    end
    # rubocop:enable MethodLength
  end
end
# rubocop:enable ClassLength

Pacto::RakeTask.new.install
