module Flex
  module Structure
    # allows deep merge between Hashes
    module Mergeable

      def deep_merge(*hashes)
        Utils.deep_merge_hashes(self, *hashes)
      end

      def deep_merge!(*hashes)
        replace deep_merge(*hashes)
      end
      alias_method :add, :deep_merge!

      def deep_dup
        Marshal.load(Marshal.dump(self))
      end

    end
  end
end
