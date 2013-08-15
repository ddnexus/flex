module Flex
  class Result

    #  adds sugar to documents with the following structure:
    #
    #    {
    #        "_index" : "twitter",
    #        "_type" : "tweet",
    #        "_id" : "1",
    #    }

    module DocumentLoader

      module ModelClasses
        extend self
        # maps all the index/types to the ruby class
        def map
          @map ||= begin
                     map = {}
                     (Conf.flex_models + Conf.flex_active_models).each do |m|
                       m = eval("::#{m}") if m.is_a?(String)
                       indices = m.flex.index.is_a?(Array) ? m.flex.index : [m.flex.index]
                       types = m.flex.type.is_a?(Array) ? m.flex.type : [m.flex.type]
                       indices.each do |i|
                         types.each { |t| map["#{i}/#{t}"] = m }
                       end
                     end
                     map
                   end
        end
      end

      # extend if result has a structure like a document
      def self.should_extend?(result)
        result.is_a? Document
      end

      def model_class
        @model_class ||= ModelClasses.map["#{index_basename}/#{self['_type']}"]
      end

      def load
        model_class.find(self['_id']) if model_class
      end

      def load!
        raise DocumentMappingError, "the '#{index_basename}/#{self['_type']}' document cannot be mapped to any class." \
              unless model_class
        model_class.find self['_id']
      end

    end

  end
end

