module Flex
  module ClassProxy
    module RelatedModel

      include ModelSync

      alias_method :full_sync, :sync

      def sync(*synced)
        raise ArgumentError, 'You cannot flex.sync(self) a Flex::RelatedModel.' \
              if synced.any?{|s| s == host_class}
        full_sync
      end

    end
  end
end
