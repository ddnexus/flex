module Flex
  module ClassProxy
    module Model

      attr_reader :parent_association, :parent_child_map
      include ModelSync
      include CommonVars

      def init
        variables.deep_merge! :type  => Manager.class_name_to_type(context.name)
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
