module Flex
  module ClassProxy
    module ModelSyncer

      attr_accessor :synced

      def sync(*synced)
        # Flex::ActiveModel has its own way of syncing, and a Flex::ModelSyncer cannot be synced by itself
        raise ArgumentError, %(You cannot flex.sync(self) #{context}.) \
              if synced.any?{|s| s == context} && !context.include?(Flex::ModelIndexer)
        synced.each do |s|
          s == context || s.is_a?(Symbol) || s.is_a?(String) || raise(ArgumentError, "self, string or symbol expected, got #{s.inspect}")
        end
        @synced ||= []
        @synced  |= synced
        add_callbacks
      end

      def add_callbacks
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
