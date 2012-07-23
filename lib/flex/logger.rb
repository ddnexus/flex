require 'logger'

module Flex
  class Logger < ::Logger

    def initialize(*)
      super
      self.level     = ::Logger::INFO
      self.progname  = "FLEX"
      self.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end

  end
end
