module Flex
  class Result

    #  adds sugar to documents with the following structure:
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
        %w[_index _type _id _source].all? {|k| obj.has_key?(k)}
      end

      # exposes _source: automatically supply object-like reader access
      # also expose meta fields like _id, _source, etc, also for methods without the leading '_'
      def method_missing(meth, *args, &block)
        case
        when meth.to_s =~ /^_/ && has_key?(meth.to_s) then self[meth.to_s]
        when self['_source'].has_key?(meth.to_s)      then self['_source'][meth.to_s]
        when has_key?("_#{meth.to_s}")                then self["_#{meth.to_s}"]
        else super
        end
      end

      # returns the _source hash with an added id (if missing))
      def to_attributes
        {'id' => _id}.merge(_source)
      end

      # creates an instance of a mapped or computed class, falling back to OpenStruct
      def to_mapped
        to(mapped_class || OpenStruct)
      end

      # experimental: creates an instance of klass out of to_attributes
      # we should probably reset the id to the original document _id
      # but be sure the record is read-only
      def to(klass)
        obj = klass.new(to_attributes)
        case
        when defined?(ActiveRecord::Base) && obj.is_a?(ActiveRecord::Base)
          obj.readonly!
        when defined?(Mongoid::Document)  && obj.is_a?(Mongoid::Document)
          # TODO: make it readonly
        when obj.is_a?(OpenStruct)
          # TODO: anythig to extend?
        end
        obj
      end

    end
  end
end
