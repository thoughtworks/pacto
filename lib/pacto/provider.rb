module Pacto
  def self.providers
    @providers ||= {}
  end

  class Provider
    include Resettable

    def self.reset!
      Pacto.providers.clear
    end

    def actor
      @actor ||= Pacto::Actors::FromExamples.new
    end

    def actor=(actor)
      fail ArgumentError, 'The actor must respond to :build_response' unless actor.respond_to? :build_response
      @actor = actor
    end

    def response_for(contract, data = {})
      actor.build_response contract, data
    end
  end
end
