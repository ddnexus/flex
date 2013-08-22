module Flex
  module LiveReindex

    extend self

    # this method will be overridden by the flex-admin gem
    def should_prefix_index?
      false
    end

    # this method will be overridden by the flex-admin gem
    def should_track_change?
      false
    end

  end
end
