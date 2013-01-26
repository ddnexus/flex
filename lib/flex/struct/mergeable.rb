module Flex
  module Struct
    # allows deep merge between Hashes
    module Mergeable

      def deep_merge(*hashes)
        merged = deep_dup
        hashes.each {|h2| merged.replace(deep_merge_hash(merged,h2))}
        merged
      end

      def deep_merge!(*hashes)
        replace deep_merge(*hashes)
      end

      def deep_dup
        Marshal.load(Marshal.dump(self))
      end

  private

      def deep_merge_hash(h1, h2)
        h2 ||= {}
        h1.merge(h2) do |key, oldval, newval|
          case
          when oldval.is_a?(::Hash) && newval.is_a?(::Hash)
            deep_merge_hash(oldval, newval)
          when oldval.is_a?(::Array) && newval.is_a?(::Array)
              oldval + newval
          else
            newval
          end
        end
      end

    end
  end
end
