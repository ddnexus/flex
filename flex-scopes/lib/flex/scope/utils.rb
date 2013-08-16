module Flex
  class Scope < Vars
    module Utils

    private

      def array_value(value)
        (value.first.is_a?(::Array) && value.size == 1) ? value.first : value
      end

    end
  end
end
