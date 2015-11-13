# -*- encoding : utf-8 -*-
require 'pacto'
require 'thor'
require 'pacto/cli'
require 'pacto/cli/helpers'
require 'pacto/rake_task/generate_task'

module Pacto
  class RakeTask
    extend Forwardable
    include Thor::Actions
    include Rake::DSL
    include

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
        puts args
        if args.to_a.size < 3
          fail Pacto::UI.colorize('USAGE: rake pacto:generate[<request_contract_dir>, <output_dir>, <record_host>]', :yellow)
        end

        Pacto::RakeTask::GenerateTask.new(args[:input_dir], args[:output_dir], args[:host]).generate_contracts
      end
    end

    def meta_validate
      desc 'Validates a directory of contract definitions'
      task :meta_validate, :dir do |_t, args|
        run(:meta_validate, *args)
      end
    end
  end
end

Pacto::RakeTask.new.install
