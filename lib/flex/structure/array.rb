module Flex
  module Structure
    class Array < ::Array

      include Symbolize

      def push(*vals)
        super *symbolize(vals)
      end

      def <<(val)
        super symbolize(val)
      end

      def insert(*vals)
        super *symbolize(vals)
      end

      def unshift(*vals)
        super *symbolize(vals)
      end

    end
  end
end
