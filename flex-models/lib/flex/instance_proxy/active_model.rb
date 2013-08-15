module Flex
  module InstanceProxy
    class ActiveModel < ModelIndexer

      def store(*vars)
        return super unless instance.flex_indexable? # this should never happen since flex_indexable? returns true
        meth = (id.nil? || id.empty?) ? :post_store : :put_store
        Flex.send(meth, metainfo, {:data => instance.flex_source}, *vars)
      end

      def sync_self
        instance.instance_eval do
          if destroyed?
            if @skip_destroy_callbacks
              flex.remove
            else
              run_callbacks :destroy do
                flex.remove
              end
            end
          else
            run_callbacks :save do
              context = new_record? ? :create : :update
              run_callbacks(context) do
                result    = context == :create ? flex.store : flex.store(:params => { :version => _version })
                @_id      = result['_id']
                @_version = result['_version']
              end
            end
          end
        end
      end

    end
  end
end
