module Flex
  class Result

    #  adds sugar to documents with the following structure (_source is optional):
    #
    #    {
    #        "_index" : "twitter",
    #        "_type" : "tweet",
    #        "_id" : "1",
    #        "_source" : {
    #            "user" : "kimchy",
    #            "postDate" : "2009-11-15T14:12:12",
    #            "message" : "trying out Elastic Search"
    #        }
    #    }

    module Document

      # extend if result has a structure like a document
      def self.should_extend?(obj)
        %w[_index _type _id].all? {|k| obj.has_key?(k)}
      end

      def respond_to?(meth, private=false)
        smeth = meth.to_s
        readers.has_key?(smeth) || has_key?(smeth) || has_key?("_#{smeth}") || super
      end

      # exposes _source and readers: automatically supply object-like reader access
      # also expose meta readers like _id, _source, etc, also callable without the leading '_'
      def method_missing(meth, *args, &block)
        smeth = meth.to_s
        case
        # field name
        when readers.has_key?(smeth)
          readers[smeth]
        # result item
        when has_key?(smeth)
          self[smeth]
        # result item called without the '_' prefix
        when has_key?("_#{smeth}")
          self["_#{smeth}"]
        else
          super
        end
      end

      # used to get the unprefixed (by live-reindex) index name
      def index_basename
        @index_basename ||= self['_index'].sub(/^\d{14}_/, '')
      end


      private

      def readers
        @readers ||= begin
                       readers = (self['_source']||{}).merge(self['fields']||{})
                       # flattened reader for multi_readers or attachment readers
                       readers.keys.each{|k| readers[k.gsub('.','_')] = readers.delete(k) if k.include?('.')}
                       readers
                     end
      end

    end
  end
end
