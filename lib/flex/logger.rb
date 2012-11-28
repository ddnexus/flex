require 'logger'

module Flex
  class Logger < ::Logger


    def initialize(*)
      super
      self.level     = ::Logger::DEBUG
      self.progname  = "FLEX"
      self.formatter = proc do |severity, datetime, progname, msg|
        flex_format(msg)
      end
    end

    def flex_format(msg)
      prefix = Dye.dye(' FLEX ', 'FLEX:', :blue, :bold, :reversed) + ' '
      msg.split("\n").map{|l| prefix + l}.join("\n") + "\n"
    end

  end
end
