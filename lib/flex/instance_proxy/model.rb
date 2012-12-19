module Flex
  module InstanceProxy
    class Model < Base

      # indexes the document
      # usually called from after_save, you can eventually call it explicitly for example from another callback
      # or whenever the DB doesn't get updated by the model
      # you can also pass the :data=>flex_source explicitly (useful for example to override the flex_source in the model)
      def store(*vars)
        if instance.flex_indexable?
          Flex.store(metainfo, {:data => instance.flex_source}, *vars)
        else
          Flex.remove(metainfo, *vars) if Flex.get(metainfo, *vars, :raise => false)
        end
      end

      # removes the document from the index (called from after_destroy)
      def remove(*vars)
        return unless instance.flex_indexable?
        Flex.remove(metainfo, *vars)
      end

      # gets the document from ES
      def get(*vars)
        return unless instance.flex_indexable?
        Flex.get(metainfo, *vars)
      end

      def parent_instance(raise=true)
        return unless is_child?
        @parent_instance ||= instance.send(class_flex.parent_association) || raise &&
                               raise(MissingParentError, "missing parent instance for document #{instance.inspect}.")
      end

      # helper that iterates through the parent record chain
      # record.flex.each_parent{|p| p.do_something }
      def each_parent
        pi = parent_instance
        while pi do
          yield pi
          pi = pi.flex.parent_instance
        end
      end

      def type
        @type ||= is_child? ? class_flex.parent_child_map[parent_instance.flex.type] : class_flex.type
      end

      def index
        class_flex.index
      end

      def id
        instance.id.to_s
      end

      def routing(raise=true)
        @routing ||= case
                     when is_child?  then parent_instance(raise).flex.routing
                     when is_parent? then create_routing
                     end
      end

      def is_child?
        @is_child ||= class_flex.is_child?
      end

      def is_parent?
        @is_parent ||= Manager.parent_types.include?(type)
      end

      def metainfo
        meta = Vars.new( :index => index, :type => type, :id => id )
        params = {}
        params[:routing] = routing if routing
        params[:parent]  = parent_instance.id.to_s if is_child?
        meta.merge!(:params => params) unless params.empty?
        meta
      end

      private

      BASE62_DIGITS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a

      def create_routing
        string    = [index, type, id].join
        remainder = Digest::MD5.hexdigest(string).to_i(16)
        result    = []
        max_power = ( Math.log(remainder) / Math.log(62) ).floor
        max_power.downto(0) do |power|
          digit, remainder = remainder.divmod(62**power)
          result << digit
        end
        result << remainder if remainder > 0
        result.map{|digit| BASE62_DIGITS[digit]}.join
      end

    end
  end
end
