RSpec::Matchers.define :have_investigated do |service_name|
  match do
    @service_name = service_name
    @contract = Pacto.contract_registry.find_by_name service_name
    investigated?
  end

  chain :with_request do |request_constraints|
    @request_constraints = request_constraints
  end

  chain :with_response do |response_constraints|
    @response_constraints = response_constraints
  end

  def investigated?
    @investigations = Pacto::InvestigationRegistry.instance.investigations
    @matching_investigations = @investigations.select { |i| i.contract == @contract }
    return false if @matching_investigations.nil?

    if @request_constraints
      # ...
    end
    if @response_constraints
      # ...
    end
    @investigations.all? { |i| i.successful? }
  end

  def investigation_citations
    @investigation_citations ||= @matching_investigations.map(&:citations).flatten.compact
  end

  def unsuccessful_investigations
    @matching_investigations.select { |i| !i.successful? }
  end

  def successfully?
    unsuccessful_investigations.empty?
  end

  def contract_matches?
    if @contract
      validated_contracts = @matching_investigations.map(&:contract).compact
      # Is there a better option than case equality for string & regex support?
      validated_contracts.map(&:name).index { |name| @contract === name } # rubocop:disable CaseEquality
    else
      true
    end
  end

  failure_message_for_should do
    buffer = StringIO.new
    buffer.puts "expected Pacto to have investigated #{@service_name}"
    buffer.puts "  with request matching #{@request_constraints}" if @request_constraints
    buffer.puts '  and' if @request_constraints && @response_constraints
    buffer.puts "  with response matching #{@response_constraints}" if @response_constraints
    if @matching_investigations.nil? || @matching_investigations.empty?
      buffer.puts '  but it was not investigated'
      buffer.puts '    investigated:'
      buffer.puts "#{@investigations.map(&:contract).compact.map(&:name).uniq}"
    elsif !successfully?
      buffer.puts '  but investigation errors were found:'
      unsuccessful_investigations.each do |investigation|
        buffer.puts "    #{investigation}"
      end
    end
    buffer.string
  end
end
