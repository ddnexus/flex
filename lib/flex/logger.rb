require 'logger'

module Flex
  class Logger < ::Logger


    attr_accessor :debug_variables, :debug_request, :debug_result, :curl_format

    def initialize(*)
      super
      self.level     = ::Logger::WARN
      self.progname  = 'FLEX'
      self.formatter = proc do |severity, datetime, progname, msg|
        flex_format(severity, msg)
      end
      @debug_variables = true
      @debug_request   = true
      @debug_result    = true
      @curl_format     = false
    end

    def flex_format(severity, msg)
      prefix = Dye.dye(" FLEX-#{severity} ", "FLEX-#{severity}:", :blue, :bold, :reversed) + ' '
      msg.split("\n").map{|l| prefix + l}.join("\n") + "\n"
    end

    # force color in console (used with jruby)
    def color=(bool)
      Dye.color = bool
    end

    def color
      Dye.color?
    end

  end
end
