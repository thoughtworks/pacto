module Pacto
  module Provider
    include Resettable

    def self.reset!
      @actor  = nil
      @driver = nil
    end

    def self.actor
      @actor ||= Pacto::Actors::JSONGenerator
    end

    def self.actor=(actor)
      fail ArgumentError, 'The actor must respond to :build_response' unless actor.respond_to? :build_response
      @actor = actor
    end

    def self.response_for(contract, data = {})
      actor.build_response contract, data
    end
  end
end
