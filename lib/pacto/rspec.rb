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

  def validated?(request_pattern)
    @matching_validations = Pacto::ValidationRegistry.instance.validated? @request_pattern
    validated = @matching_validations
    validated && contract_matches?
  end

  def contract_matches?
    if @contract
      validated_contracts = @matching_validations.map(&:contract)
      validated_contracts.map(&:file).include? @contract
    else
      true
    end
  end

  failure_message_for_should do
    buffer = StringIO.new
    buffer.puts "expected Pacto to have validated #{@request_pattern}"
    if @matching_validations.nil? || @matching_validations.empty?
      buffer.puts "  but no matching request was received"
      buffer.puts "    received:"
      buffer.puts "#{WebMock::RequestRegistry.instance}"
    elsif @matching_validations.map(&:contract).compact.empty?
      buffer.puts "  but a matching Contract was not found"
    elsif @contract
      validated_against = @matching_validations.map{ |v| v.contract.file if v.contract }.join ','
      buffer.puts "  against Contract #{@contract}"
      buffer.puts "    but it was validated against #{validated_against}"
    end
    buffer.string
  end
end
