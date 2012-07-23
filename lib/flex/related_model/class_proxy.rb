module Flex
  module RelatedModel
    class ClassProxy

      attr_reader :host_class

      def initialize(host_class)
        @host_class = host_class
      end

      include RelatedModel::ClassSync

      alias_method :full_sync, :sync

      def sync(*synced)
        raise ArgumentError, 'You cannot flex.sync(self) a Flex::RelatedModel.' \
              if synced.any?{|s| s == host_class}
        full_sync
      end

    end
  end
end
