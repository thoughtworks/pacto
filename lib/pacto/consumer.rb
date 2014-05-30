module Pacto
  module Consumer
    include Resettable

    def self.reset!
      @actor  = nil
      @driver = nil
    end

    def self.actor
      @actor ||= Pacto::Actors::JSONGenerator
    end

    def self.build_request(contract, data = {})
      actor.build_request contract, data
    end

    def self.build_response(contract, data = {})
      actor.build_response contract, data
    end

    def self.reenact(contract, data = {})
      request = build_request contract, data
      response = driver.execute request
      [request, response]
    end

    def self.actor=(actor)
      fail ArgumentError('The actor must respond to :build_request') unless actor.respond_to? :build_request
      @actor = actor
    end

    # Returns the current driver
    def self.driver
      @driver ||= Pacto::Consumer::FaradayDriver.new
    end

    # Changes the driver
    def self.driver=(driver)
      fail ArgumentError('The driver must respond to :execute') unless driver.respond_to? :execute
      @driver = driver
    end
  end
end
