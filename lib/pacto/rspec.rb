require 'pacto'

begin
  require 'rspec/core'
  require 'rspec/expectations'
rescue LoadError
  raise 'pacto/rspec requires rspec 2 or later'
end

RSpec::Matchers.define :have_validated do |method, uri|
  @request_pattern = WebMock::RequestPattern.new(method, uri)
  match do
    validated? @request_pattern
  end

  chain :against_contract do |contract|
    @contract = contract
  end

  chain :with do |options|
    @request_pattern.with options
  end

  def validated?(request_pattern)
    @matching_validations = Pacto::ValidationRegistry.instance.validated? @request_pattern
    validated = !@matching_validations.nil?
    validated && successfully? && contract_matches?
  end

  def validation_results
    @validation_results ||= @matching_validations.map(&:results).flatten.compact
  end

  def successfully?
    @matching_validations.map(&:successful?).uniq.eql? [true]
  end

  def contract_matches?
    if @contract
      validated_contracts = @matching_validations.map(&:contract)
      # Is there a better option than case equality for string & regex support?
      validated_contracts.map(&:file).index { |file| @contract === file } # rubocop:disable CaseEquality
    else
      true
    end
  end

  failure_message_for_should do
    buffer = StringIO.new
    buffer.puts "expected Pacto to have validated #{@request_pattern}"
    if @matching_validations.nil? || @matching_validations.empty?
      buffer.puts '  but no matching request was received'
      buffer.puts '    received:'
      buffer.puts "#{WebMock::RequestRegistry.instance}"
    elsif @matching_validations.map(&:contract).compact.empty?
      buffer.puts '  but a matching Contract was not found'
    elsif !successfully?
      buffer.puts '  but validation errors were found:'
      buffer.puts "  #{validation_results}"
    elsif @contract
      validated_against = @matching_validations.map { |v| v.against_contract?  @contract }.compact.join ','
      buffer.puts "  against Contract #{@contract}"
      buffer.puts "    but it was validated against #{validated_against}"
    end
    buffer.string
  end
end
