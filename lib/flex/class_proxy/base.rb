module Flex
  module ClassProxy
    class Base

      attr_reader :context
      attr_accessor :variables

      def initialize(context, vars={})
        @context   = context
        @variables = Variables.new({:context => context}.merge(vars))
      end

      def init; end

    end
  end
end
