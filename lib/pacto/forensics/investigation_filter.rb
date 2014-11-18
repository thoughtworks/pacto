# -*- encoding : utf-8 -*-
module Pacto
  module Forensics
    class FilterExhaustedError < StandardError
      attr_reader :suspects

      def initialize(msg, filter, suspects = [])
        @suspects = suspects
        if filter.respond_to? :description
          msg = "#{msg} #{filter.description}"
        else
          msg = "#{msg} #{filter}"
        end
        super(msg)
      end
    end

    class InvestigationFilter
      # CaseEquality makes sense for some of the rspec matchers and compound matching behavior
      # rubocop:disable Style/CaseEquality
      attr_reader :investigations, :filtered_investigations

      def initialize(investigations, track_suspects = true)
        investigations ||= []
        @investigations = investigations.dup
        @filtered_investigations = @investigations.dup
        @track_suspects = track_suspects
      end

      def with_name(contract_name)
        @filtered_investigations.keep_if do |investigation|
          return false if investigation.contract.nil?

          contract_name === investigation.contract.name
        end
        self
      end

      def with_request(request_constraints)
        return self if request_constraints.nil?
        [:headers, :body].each do |section|
          filter_request_section(section, request_constraints[section])
        end
        self
      end

      def with_response(response_constraints)
        return self if response_constraints.nil?
        [:headers, :body].each do |section|
          filter_response_section(section, response_constraints[section])
        end
        self
      end

      def successful_investigations
        @filtered_investigations.select(&:successful?)
      end

      def unsuccessful_investigations
        @filtered_investigations - successful_investigations
      end

      protected

      def filter_request_section(section, filter)
        suspects = []
        section = :parsed_body if section == :body
        @filtered_investigations.keep_if do |investigation|
          candidate = investigation.request.send(section)
          suspects << candidate if @track_suspects
          filter === candidate
        end if filter
        fail FilterExhaustedError.new("no requests matched #{section}", filter, suspects) if @filtered_investigations.empty?
      end

      def filter_response_section(section, filter)
        section = :parsed_body if section == :body
        suspects = []
        @filtered_investigations.keep_if do |investigation|
          candidate = investigation.response.send(section)
          suspects << candidate if @track_suspects
          filter === candidate
        end if filter
        fail FilterExhaustedError.new("no responses matched #{section}", filter, suspects) if @filtered_investigations.empty?
      end

      # rubocop:enable Style/CaseEquality
    end
  end
end
