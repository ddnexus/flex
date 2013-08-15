module Flex
  module Rails
    module Helper
      extend self

      def after_initialize
        # we need to reload the flex API methods with the new variables
        Flex.reload!
        Conf.flex_models && Conf.flex_models.each {|m| eval"::#{m}" if m.is_a?(String) }
      end

    end
  end
end
