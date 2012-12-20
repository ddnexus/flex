module Flex
  module InstanceProxy

    class Base
      attr_reader :instance, :class_flex

      def initialize(instance)
        @instance   = instance
        @class_flex = instance.class.flex
      end

      def sync(*trail)
        return if trail.include?(self) || class_flex.synced.nil?
        trail << self
        class_flex.synced.each do |synced|
          case
          # sync self
          # only called for Flex::Model
          when synced == instance.class
            instance.destroyed? ? remove : store
          # sync :author, :comments
          # works for all association types, if the instances have a #flex proxy (i.e. Flex::Models)
          when synced.is_a?(Symbol)
            to_sync = instance.send(synced)
            if to_sync.respond_to?(:each)
              to_sync.each { |s| s.flex.sync(*trail) }
            else
              to_sync.flex.sync(*trail)
            end
          # sync 'blog'
          # polymorphic: use this form only if you want to sync any specific parent type but not all
          when synced.is_a?(String)
            next unless synced == parent_instance.flex.type
            parent_instance.flex.sync(*trail)
          else
            raise ArgumentError, "self, string or symbol expected, got #{synced.inspect}"
          end
        end
      end

    end
  end
end
