class InvalidContract < ArgumentError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
  end

  def message
    @errors.join "\n"
  end
end
