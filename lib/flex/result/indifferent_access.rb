module Flex
  module Result
    module IndifferentAccess

      def self.extended(result)
        result.extend Struct::IndifferentAccess
      end

    end
  end
end
