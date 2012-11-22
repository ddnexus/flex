module Flex
  module ClassProxy
    module IndexType

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

    end
  end
end
