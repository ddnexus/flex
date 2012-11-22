module Flex
  module ClassProxy
    module ModelSync

      attr_accessor :synced

      def sync(*synced)
        @synced = synced
        context.class_eval do
          raise NotImplementedError, "the class #{self} must implement :after_save and :after_destroy callbacks" \
                unless respond_to?(:after_save) && respond_to?(:after_destroy)
          after_save    { flex.sync }
          after_destroy { flex.sync }
        end
      end

    end
  end
end
