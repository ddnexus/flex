module Flex
  module ClassProxy
    class Base

      attr_reader :host_class
      attr_accessor :variables

      def initialize(host_class, vars={})
        @host_class = host_class
        @variables  = Variables.new({:context => host_class}.merge(vars))
      end

      def init; end

    end
  end
end
