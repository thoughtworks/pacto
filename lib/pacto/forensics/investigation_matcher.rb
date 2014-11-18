# -*- encoding : utf-8 -*-
RSpec::Matchers.define :have_investigated do |service_name|
  match do
    investigations = Pacto::InvestigationRegistry.instance.investigations
    @service_name = service_name

    begin
      @investigation_filter = Pacto::Forensics::InvestigationFilter.new(investigations)
      @investigation_filter.with_name(@service_name)
        .with_request(@request_constraints)
        .with_response(@response_constraints)

      @matched_investigations = @investigation_filter.filtered_investigations
      @unsuccessful_investigations = @investigation_filter.unsuccessful_investigations

      !@matched_investigations.empty? && (@allow_citations || @unsuccessful_investigations.empty?)
    rescue Pacto::Forensics::FilterExhaustedError => e
      @filter_error = e
      false
    end
  end

  def describe(obj)
    obj.respond_to?(:description) ? obj.description : obj.to_s
  end

  description do
    buffer = StringIO.new
    buffer.puts "to have investigated #{@service_name}"
    if @request_constraints
      buffer.puts '  with request matching'
      @request_constraints.each do |k, v|
        buffer.puts "    #{k}: #{describe(v)}"
      end
    end
    buffer.puts '  and' if @request_constraints && @response_constraints
    if @response_constraint
      buffer.puts '  with response matching'
      @request_constraints.each do |k, v|
        buffer.puts "    #{k}: #{describe(v)}"
      end
    end
    buffer.string
  end

  chain :with_request do |request_constraints|
    @request_constraints = request_constraints
  end

  chain :with_response do |response_constraints|
    @response_constraints = response_constraints
  end

  chain :allow_citations do
    @allow_citations = true
  end

  failure_message do | group |
    buffer = StringIO.new
    buffer.puts "expected #{group} " + description
    if @filter_error
      buffer.puts "but #{@filter_error.message}"
      unless @filter_error.suspects.empty?
        buffer.puts '  suspects:'
        @filter_error.suspects.each do |suspect|
          buffer.puts "    #{suspect}"
        end
      end
    elsif @matched_investigations.empty?
      investigated_services = @investigation_filter.investigations.map(&:contract).compact.map(&:name).uniq
      buffer.puts "but it was not among the services investigated: #{investigated_services}"
    elsif @unsuccessful_investigations
      buffer.puts 'but investigation errors were found:'
      @unsuccessful_investigations.each do |investigation|
        buffer.puts "  #{investigation}"
      end
    end
    buffer.string
  end
end
