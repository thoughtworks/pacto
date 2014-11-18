# -*- encoding : utf-8 -*-
module Pacto
  def self.consumers
    @consumers ||= {}
  end

  def self.simulate_consumer(consumer_name = :consumer, &block)
    consumers[consumer_name] ||= Consumer.new(consumer_name)
    consumers[consumer_name].simulate(&block)
  end

  class Consumer
    include Logger
    include Resettable

    def initialize(name = :consumer)
      @name = name
    end

    def simulate(&block)
      instance_eval(&block)
    end

    def playback(stenographer_script)
      script = File.read(stenographer_script)
      instance_eval script, stenographer_script
    end

    def self.reset!
      Pacto.consumers.clear
    end

    def actor
      @actor ||= Pacto::Actors::FromExamples.new
    end

    def actor=(actor)
      fail ArgumentError, 'The actor must respond to :build_request' unless actor.respond_to? :build_request
      @actor = actor
    end

    def request(contract, data = {})
      contract = Pacto.contract_registry.find_by_name(contract) if contract.is_a? String
      logger.info "Sending request to #{contract.name.inspect}"
      logger.info "  with #{data.inspect}"
      reenact(contract, data)
    rescue ContractNotFound => e
      logger.warn "Ignoring request: #{e.message}"
    end

    def reenact(contract, data = {})
      request = build_request contract, data
      response = driver.execute request
      [request, response]
    end

    # Returns the current driver
    def driver
      @driver ||= Pacto::Consumer::FaradayDriver.new
    end

    # Changes the driver
    def driver=(driver)
      fail ArgumentError, 'The driver must respond to :execute' unless driver.respond_to? :execute
      @driver = driver
    end

    # @api private
    def build_request(contract, data = {})
      actor.build_request(contract, data[:values]).tap do |request|
        if data[:headers] && data[:headers].respond_to?(:call)
          request.headers = data[:headers].call(request.headers)
        end
        if data[:body] && data[:body].respond_to?(:call)
          request.body = data[:body].call(request.body)
        end
      end
    end
  end
end
