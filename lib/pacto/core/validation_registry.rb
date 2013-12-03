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

  def unmatched_validations
    @validations.select do |validation|
      validation.contract.nil?
    end
  end

  def failed_validations
    @validations.select do |validation|
      !validation.successful?
    end
  end
end
