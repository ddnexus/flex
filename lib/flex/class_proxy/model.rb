module Flex
  module ClassProxy
    class Model < Base

      include ModelSync

      attr_reader :parent_association, :parent_child_map

      def initialize(base)
        super
        variables.add :index => Configuration.variables[:index],
                      :type  => Manager.class_name_to_type(host_class.name)
      end

      def index
        variables[:index]
      end

      def index=(val)
        variables[:index] = val
      end

      def type
        variables[:type]
      end

      def type=(val)
        variables[:type] = val
      end

      def parent(parent_association, map)
        @parent_association = parent_association
        Manager.parent_types |= map.keys.map(&:to_s)
        self.type = map.values.map(&:to_s)
        @parent_child_map = map
        @is_child         = true
      end

      def is_child?
        !!@is_child
      end

    end
  end
end
