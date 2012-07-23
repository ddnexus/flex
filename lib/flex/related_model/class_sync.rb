module Flex
  module RelatedModel
    module ClassSync

      def self.included(base)
        base.class_eval do
          attr_accessor :synced
        end
      end

      def sync(*synced)
        @synced = synced
        host_class.class_eval do
          raise NotImplementedError, "the class #{self} must implement :after_save and :after_destroy callbacks" \
                  unless respond_to?(:after_save) && respond_to?(:after_destroy)
          after_save    { flex.sync }
          after_destroy { flex.sync }
        end
      end

    end
  end
end
