module Flex
  module ClassProxy
    class RelatedModel

      attr_reader :host_class

      def initialize(host_class)
        @host_class = host_class
      end

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
