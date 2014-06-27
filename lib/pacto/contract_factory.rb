require 'pacto/native_contract_factory'

module Pacto
  class ContractFactory
    include Logger

    def initialize
      @factories = {
        default: NativeContractFactory.new
      }
    end

    def add_factory(format, factory)
      @factories[format] = factory
    end

    def remove_factory(format)
      @factories.delete format
    end

    def build(contract_files, host, format = :default)
      factory = @factories[format]
      fail "No Contract factory registered for #{format}" if factory.nil?

      contract_files.map { |file| factory.build_from_file(file, host) }.flatten
    end
  end
end
