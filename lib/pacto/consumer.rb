module Pacto
  def self.simulate_consumer(consumer_name = :consumer, &block)
    Consumer.new(consumer_name).simulate(&block)
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
      @actor  = nil
      @driver = nil
    end

    def self.actor
      @actor ||= Pacto::Actors::FromExamples.new
    end

    def self.actor=(actor)
      fail ArgumentError, 'The actor must respond to :build_request' unless actor.respond_to? :build_request
      @actor = actor
    end

    def request(contract, data = {})
      contract = Pacto.contract_registry.find_by_name(contract) if contract.is_a? String
      values = data[:values]
      # response = data[:response]
      logger.info "Sending request to #{contract.name.inspect}"
      logger.info "  with #{values.inspect} values"
      self.class.reenact(contract, values)
    rescue ContractNotFound => e
      logger.warn "Ignoring request: #{e.message}"
    end

    def self.build_request(contract, data = {})
      actor.build_request contract, data
    end

    def self.reenact(contract, data = {})
      request = build_request contract, data
      response = driver.execute request
      [request, response]
    end

    # Returns the current driver
    def self.driver
      @driver ||= Pacto::Consumer::FaradayDriver.new
    end

    # Changes the driver
    def self.driver=(driver)
      fail ArgumentError, 'The driver must respond to :execute' unless driver.respond_to? :execute
      @driver = driver
    end
  end
end
