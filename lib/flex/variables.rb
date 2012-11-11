module Flex
  class Variables < Hash

    include Structure::Mergeable

    def initialize(hash=nil)
      hash ||= {} # accepts an explicit nil
      replace hash
    end

  end
end
