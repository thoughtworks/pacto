require 'pacto'

begin
  require 'rspec/core'
  require 'rspec/expectations'
rescue LoadError
  raise 'pacto/rspec requires rspec 2 or later'
end

require 'pacto/forensics/investigation_matcher'

RSpec::Matchers.define :have_unmatched_requests do |_method, _uri|
  match do
    @unmatched_investigations = Pacto::InvestigationRegistry.instance.unmatched_investigations
    !@unmatched_investigations.empty?
  end

  failure_message_for_should do
    'Expected Pacto to have not matched all requests to a Contract, but all requests were matched.'
  end

  failure_message_for_should_not do
    unmatched_requests = @unmatched_investigations.map(&:request).join("\n  ")
    "Expected Pacto to have matched all requests to a Contract, but the following requests were not matched: \n  #{unmatched_requests}"
  end
end

RSpec::Matchers.define :have_failed_investigations do |_method, _uri|
  match do
    @failed_investigations = Pacto::InvestigationRegistry.instance.failed_investigations
    !@failed_investigations.empty?
  end

  failure_message_for_should do
    'Expected Pacto to have found investigation problems, but none were found.'
  end

  failure_message_for_should_not do
    "Expected Pacto to have successfully validated all requests, but the following issues were found: #{@failed_investigations}"
  end
end

RSpec::Matchers.define :have_validated do |method, uri|
  match do
    @request_pattern = WebMock::RequestPattern.new(method, uri)
    @request_pattern.with(@options) if @options
    validated? @request_pattern
  end

  chain :against_contract do |contract|
    @contract = contract
  end

  chain :with do |options|
    @options = options
  end

  def validated?(_request_pattern)
    @matching_investigations = Pacto::InvestigationRegistry.instance.validated? @request_pattern
    validated = !@matching_investigations.nil?
    validated && successfully? && contract_matches?
  end

  def investigation_citations
    @investigation_citations ||= @matching_investigations.map(&:citations).flatten.compact
  end

  def successfully?
    @matching_investigations.map(&:successful?).uniq.eql? [true]
  end

  def contract_matches?
    if @contract
      validated_contracts = @matching_investigations.map(&:contract).compact
      # Is there a better option than case equality for string & regex support?
      validated_contracts.any? do |contract|
        @contract === contract.file || @contract === contract.name # rubocop:disable CaseEquality
      end
    else
      true
    end
  end

  failure_message_for_should do
    buffer = StringIO.new
    buffer.puts "expected Pacto to have validated #{@request_pattern}"
    if @matching_investigations.nil? || @matching_investigations.empty?
      buffer.puts '  but no matching request was received'
      buffer.puts '    received:'
      buffer.puts "#{WebMock::RequestRegistry.instance}"
    elsif @matching_investigations.map(&:contract).compact.empty?
      buffer.puts '  but a matching Contract was not found'
    elsif !successfully?
      buffer.puts '  but investigation errors were found:'
      buffer.print '    '
      buffer.puts investigation_citations.join "\n    "
      # investigation_citations.each do |investigation_result|
      #   buffer.puts "    #{investigation_result}"
      # end
    elsif @contract
      validated_against = @matching_investigations.map { |v| v.against_contract? @contract }.compact.join ','
      buffer.puts "  against Contract #{@contract}"
      buffer.puts "    but it was validated against #{validated_against}"
    end
    buffer.string
  end
end
