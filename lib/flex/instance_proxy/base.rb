module Flex
  module InstanceProxy

    class Base
      attr_reader :instance, :class_flex

      def initialize(instance)
        @instance   = instance
        @class_flex = instance.class.flex
      end

      def sync
        class_flex.synced.each do |s|
          case
          when s == instance.class               # only called for Flex::Model
            instance.destroyed? ? remove : store
          when s.is_a?(Symbol)
            instance.send(s).flex.sync
          when s.is_a?(String)
            parent_instance.flex.sync if s == parent_instance.flex.type
          else
            raise ArgumentError, "self, string or symbol expected, got #{s.inspect}"
          end
        end
      end

    end
  end
end
