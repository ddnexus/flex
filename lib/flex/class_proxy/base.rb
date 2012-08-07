module Flex
  module ClassProxy

    class Base
      attr_reader :host_class
      attr_accessor :variables

      def initialize(host_class)
        @host_class = host_class
        @variables  = Variables.new
      end
    end

  end
end
