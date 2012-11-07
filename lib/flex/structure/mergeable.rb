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

      def add(*hashes)
        Flex::Configuration.logger.warn "Variables#add has been deprecated in favour of Variables.deep_merge! and will be removed in a next version."
        replace deep_merge(*hashes)
      end

      def deep_dup
        Marshal.load(Marshal.dump(self))
      end

    end
  end
end
