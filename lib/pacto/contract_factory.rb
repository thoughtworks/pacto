# -*- encoding : utf-8 -*-
module Pacto
  class ContractFactory
    include Singleton
    include Logger

    def initialize
      @factories = {}
    end

    def add_factory(format, factory)
      @factories[format.to_sym] = factory
    end

    def remove_factory(format)
      @factories.delete format
    end

    def build(contract_files, host, format = :default)
      factory = @factories[format.to_sym]
      fail "No Contract factory registered for #{format}" if factory.nil?

      contract_files.map { |file| factory.build_from_file(file, host) }.flatten
    end

    def load_contracts(contracts_path, host, format = :default)
      factory = @factories[format.to_sym]
      files = factory.files_for(contracts_path)
      contracts = ContractFactory.build(files, host, format)
      contracts
    end

    class << self
      extend Forwardable
      def_delegators :instance, *ContractFactory.instance_methods(false)
    end
  end
end

require 'pacto/legacy_contract_factory'
require 'pacto/swagger_contract_factory'
