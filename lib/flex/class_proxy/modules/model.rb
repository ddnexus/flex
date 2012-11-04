module Flex
  module ClassProxy
    module Modules
      module Model

        def self.included(base)
          base.class_eval do
            attr_reader :parent_association, :parent_child_map
            include ModelSync
          end
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
end
