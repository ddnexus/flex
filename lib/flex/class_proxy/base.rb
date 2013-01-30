module Flex
  module ClassProxy
    class Base

      attr_accessor :variables

      def initialize(context, vars={})
        @variables = Vars.new({:context => context,
                               :index   => Conf.variables[:index]}.merge(vars))
      end

      def init; end

      [:context, :index, :type, :params].each do |meth|
        define_method meth do
          variables[meth]
        end
        define_method :"#{meth}=" do |val|
          variables[meth] = val
        end
      end

      def refresh_index
        Flex.refresh_index :index => index
      end

    end
  end
end
