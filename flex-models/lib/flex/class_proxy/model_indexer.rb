module Flex
  module ClassProxy
    module ModelIndexer

      module Types
        extend self

        attr_accessor :parents
        @parents = []
      end

      attr_reader :parent_association, :parent_child_map

      def init
        variables.deep_merge! :type  => Utils.class_name_to_type(context.name)
      end

      def parent(parent_association, map)
        @parent_association = parent_association
        Types.parents      |= map.keys.map(&:to_s)
        self.type           = map.values.map(&:to_s)
        @parent_child_map   = map
        @is_child           = true
      end

      def is_child?
        !!@is_child
      end

      def is_parent?
        @is_parent ||= Types.parents.include?(type)
      end

      def default_mapping
        default = {}.extend Struct::Mergeable
        if is_child?
          parent_child_map.each do |parent, child|
            default.deep_merge! index => {'mappings' => {child => {'_parent' => {'type' => parent}}}}
          end
        end
        default
      end

    end
  end
end
