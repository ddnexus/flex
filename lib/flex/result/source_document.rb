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

    module SourceDocument

      # extend if result has a structure like a document
      def self.should_extend?(obj)
        %w[_index _type _id].all? {|k| obj.has_key?(k)}
      end

      # exposes _source: automatically supply object-like reader access
      # also expose meta fields like _id, _source, etc, also for methods without the leading '_'
      def method_missing(meth, *args, &block)
        case
        when meth.to_s =~ /^_/ && has_key?(meth.to_s)
          self[meth.to_s]
        when self['_source'] && self['_source'].has_key?(meth.to_s)
          self['_source'][meth.to_s]
        when has_key?("_#{meth.to_s}")
          self["_#{meth.to_s}"]
        else
          super
        end
      end

    end
  end
end
