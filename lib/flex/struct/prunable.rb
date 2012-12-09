module Flex
  module Struct
    module Prunable

      extend self

      VALUES = [ nil, '', {}, [], false ]

      class Value
        class << self
          def to_s; '' end
          alias_method :===, :==
        end
      end

      def prune_blanks(obj)
        prune(obj, *VALUES) || {}
      end

      # prunes the branch when the leaf is Prunable
      # and compact.flatten the Array values
      # values are the prunable values, like VALUES or Prunable::Value,
      # or any arbitrary value
      def prune(obj, *values)
        case
        when values.include?(obj)
          obj
        when obj.is_a?(::Array)
          return obj if obj.empty?
          ar = []
          obj.each do |i|
            pruned = prune(i, *values)
            next if values.include?(pruned)
            ar << pruned
          end
          a = ar.compact.flatten
          a.empty? ? values.first : a
        when obj.is_a?(::Hash)
          return obj if obj.empty?
          h = {}
          obj.each do |k, v|
            pruned = prune(v, *values)
            next if values.include?(pruned)
            h[k] = pruned
          end
          h.empty? ? values.first : h
        else
          obj
        end
      end

    end
  end
  Prunable = Struct::Prunable
end
