module Flex
  module Rails
    module Helper
      extend self

      def after_initialize
        # use the same app logger
        Flex::Configuration.logger = ::Rails.logger
        # we need to reload the flex API methods with the new variables
        Flex.reload!
        Flex::Manager.init_models
      end

    end
  end
end
