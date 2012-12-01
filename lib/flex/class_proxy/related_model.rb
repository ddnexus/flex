module Flex
  module ClassProxy
    module RelatedModel

      include ModelSync

      def sync(*synced)
        raise ArgumentError, 'You cannot flex.sync(self) a Flex::RelatedModel.' \
              if synced.any?{|s| s == context}
        super
      end

    end
  end
end
