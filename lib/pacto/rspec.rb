require 'pacto'

begin
  require 'rspec/core'
  require 'rspec/expectations'
rescue LoadError
  raise 'pacto/rspec requires rspec 2 or later'
end

RSpec::Matchers.define :have_unmatched_requests do |method, uri|
  @unmatched_validations = Pacto::ValidationRegistry.instance.unmatched_validations
  match do
    !@unmatched_validations.empty?
  end

  failure_message_for_should do
    'Expected Pacto to have not matched all requests to a Contract, but all requests were matched.'
  end

  failure_message_for_should_not do
    unmatched_requests = @unmatched_validations.map(&:request).join("\n  ")
    "Expected Pacto to have matched all requests to a Contract, but the following requests were not matched: \n  #{unmatched_requests}"
  end
end

RSpec::Matchers.define :have_failed_validations do |method, uri|
  @failed_validations = Pacto::ValidationRegistry.instance.failed_validations
  match do
    !@failed_validations.empty?
  end

  failure_message_for_should do
    'Expected Pacto to have found validation problems, but none were found.'
  end

  failure_message_for_should_not do
    "Expected Pacto to have successfully validated all requests, but the following issues were found: #{@failed_validations}"
  end
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
