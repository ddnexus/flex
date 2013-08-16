module Flex
  module ActiveModel
    module Timestamps

      def attribute_timestamps(props={})
        attribute_created_at props
        attribute_updated_at props
      end

      def attribute_created_at(props={})
        attribute :created_at, {:type => DateTime}.merge(props)
        before_create { self.created_at = Time.now.utc }
      end

      def attribute_updated_at(props={})
        attribute :updated_at, {:type => DateTime}.merge(props)
        before_save { self.updated_at = Time.now.utc }
      end

    end
  end
end
