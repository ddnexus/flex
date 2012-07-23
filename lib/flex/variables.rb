module Flex
  class Variables < Hash

    include Structure::Mergeable

    def initialize(hash={})
      replace hash
    end

  end
end
