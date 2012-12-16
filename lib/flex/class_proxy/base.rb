module Flex
  module ClassProxy
    class Base

      attr_accessor :variables

      def initialize(context, vars={})
        @variables = Vars.new({:context => context,
                               :index   => Conf.variables[:index]}.merge(vars))
      end

      def context
        variables[:context]
      end

      def context=(context)
        variables[:context] = context
      end

      def init; end

    end
  end
end
