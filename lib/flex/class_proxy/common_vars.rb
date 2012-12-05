module Flex
  module ClassProxy
    module CommonVars

      def index
        variables[:index]
      end

      def index=(val)
        variables[:index] = val
      end

      def type
        variables[:type]
      end

      def type=(val)
        variables[:type] = val
      end

      def params
        variables[:params]
      end

      def params=(val)
        variables[:params] = val
      end

    end
  end
end
