module Pacto
  class << self
    def generate!
      modes << :generate
    end

    def stop_generating!
      modes.delete :generate
    end

    def generating?
      modes.include? :generate
    end

    def validate!
      modes << :validate
    end

    def stop_validating!
      modes.delete :validate
    end

    def validating?
      modes.include? :validate
    end

    private

    def modes
      @modes ||= []
    end
  end
end
