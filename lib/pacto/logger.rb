# -*- encoding : utf-8 -*-
require 'forwardable'

module Pacto
  module Logger
    def logger
      Pacto.configuration.logger
    end

    class SimpleLogger
      include Singleton
      extend Forwardable

      def_delegators :@log, :debug, :info, :warn, :error, :fatal

      def initialize
        log ::Logger.new STDOUT
      end

      def log(log)
        @log = log
        @log.level = default_level
        @log.progname = 'Pacto'
      end

      def level=(level)
        @log.level = log_levels.fetch(level, default_level)
      end

      def level
        log_levels.key @log.level
      end

      private

      def default_level
        ::Logger::ERROR
      end

      def log_levels
        {
          debug: ::Logger::DEBUG,
          info:  ::Logger::INFO,
          warn:  ::Logger::WARN,
          error: ::Logger::ERROR,
          fatal: ::Logger::FATAL
        }
      end
    end
  end
end
