class Pacto::ValidationRegistry
  include Singleton

  def initialize
    @validations = []
  end

  def reset!
    @validations.clear
  end

  def validated? request_pattern
    matched_validations = @validations.select do |validation|
      request_pattern.matches? validation.request
    end
    matched_validations unless matched_validations.empty?
  end

  def register_validation validation
    @validations << validation
    validation
  end
end
