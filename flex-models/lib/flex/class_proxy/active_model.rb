module Flex
  module ClassProxy
    module ActiveModel

      def init(*vars)
        variables.deep_merge! *vars
      end

      def default_mapping
        props = { }
        context.attributes.each do |name, attr|
          options     = attr.send(:options)
          props[name] = case
                        when options.has_key?(:properties)
                          Utils.keyfy(:to_s, attr.send(:options)[:properties])
                        when options.has_key?(:not_analyzed) && options[:not_analyzed] ||
                             options.has_key?(:analyzed)     && !options[:analyzed]
                          { 'type' => 'string', 'index' => 'not_analyzed' }
                        when options[:type] == DateTime
                          { 'type' => 'date', 'format' => 'dateOptionalTime' }
                        else
                          next
                        end
        end
        props.empty? ? super :  super.deep_merge(index => {'mappings' => {type => {'properties' => props}}})
      end

      # overrides the ModelSyncer#add_callbacks
      def add_callbacks
        # no callbacks to add, since it calls flex.sync on save and destroy
      end

    end
  end
end
