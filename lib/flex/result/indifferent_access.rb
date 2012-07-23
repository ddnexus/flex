module Flex
  module Result
    module IndifferentAccess

      def self.extended(result)
        result.extend Structure::IndifferentAccess
      end

    end
  end
end
