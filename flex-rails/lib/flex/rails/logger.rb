module Flex
  module Rails
    class Logger < Flex::Logger

      attr_accessor :log_to_rails_logger, :log_to_stderr

      def initialize(*)
        super
        self.formatter = proc do |severity, datetime, progname, msg|
          flex_formatted = flex_format(severity, msg)
          ::Rails.logger.send(severity.downcase.to_sym, flex_formatted) if log_to_rails_logger && ::Rails.logger.respond_to?(severity.downcase.to_sym)
          flex_formatted if log_to_stderr
        end
        @log_to_rails_logger = true
        @log_to_stderr       = false
      end

      def log_to_stdout
        Deprecation.warn 'Flex::Configuration.logger.log_to_stdout', 'Flex::Configuration.logger.log_to_stderr'
        log_to_stderr
      end
      def log_to_stdout=(val)
        Deprecation.warn 'Flex::Configuration.logger.log_to_stdout=', 'Flex::Configuration.logger.log_to_stderr='
        self.log_to_stderr = val
      end

    end
  end
end
