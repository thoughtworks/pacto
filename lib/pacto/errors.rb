module Pacto
  class InvalidContract < ArgumentError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def message
      @errors.join "\n"
    end
  end

  module Errors
    # Creates an array of strings, representing a formatted exception,
    # containing backtrace and nested exception info as necessary, that can
    # be viewed by a human.
    #
    # For example:
    #
    #     ------Exception-------
    #     Class: Crosstest::StandardError
    #     Message: Failure starting the party
    #     ---Nested Exception---
    #     Class: IOError
    #     Message: not enough directories for a party
    #     ------Backtrace-------
    #     nil
    #     ----------------------
    #
    # @param exception [::StandardError] an exception
    # @return [Array<String>] a formatted message
    def self.formatted_trace(exception)
      arr = formatted_exception(exception).dup
      last = arr.pop
      if exception.respond_to?(:original) && exception.original
        arr += formatted_exception(exception.original, 'Nested Exception')
        last = arr.pop
      end
      arr += ['Backtrace'.center(22, '-'), exception.backtrace, last].flatten
      arr
    end

    # Creates an array of strings, representing a formatted exception that
    # can be viewed by a human. Thanks to MiniTest for the inspiration
    # upon which this output has been designed.
    #
    # For example:
    #
    #     ------Exception-------
    #     Class: Crosstest::StandardError
    #     Message: I have failed you
    #     ----------------------
    #
    # @param exception [::StandardError] an exception
    # @param title [String] a custom title for the message
    #   (default: `"Exception"`)
    # @return [Array<String>] a formatted message
    def self.formatted_exception(exception, title = 'Exception')
      [
        title.center(22, '-'),
        "Class: #{exception.class}",
        "Message: #{exception.message}",
        ''.center(22, '-')
      ]
    end
  end
end
