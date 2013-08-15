module Flex
  class Result
    module SearchLoader

      # extend if result is a Search or MultiGet
      def self.should_extend?(result)
        result.is_a?(Search) || result.is_a?(MultiGet)
      end

      # extend the collection on extend
      def self.extended(result)
        result.collection.each { |h| h.extend(DocumentLoader) }
      end

      def loaded_collection
        @loaded_collection ||= begin
                                 records  = []
                                 # returns a structure like {Comment=>[{"_id"=>"123", ...}, {...}], BlogPost=>[...]}
                                 h = Utils.group_array_by(collection) do |d|
                                   d.model_class
                                 end
                                 h.each do |klass, docs|
                                   records |= klass.find(docs.map(&:_id))
                                 end
                                 class_ids = collection.map { |d| [d.model_class.to_s,  d._id] }
                                 # Reorder records to preserve order from search results
                                 records = class_ids.map do |class_str, id|
                                   records.detect do |record|
                                     record.class.to_s == class_str && record.id.to_s == id.to_s
                                   end
                                 end
                                 records.extend Struct::Paginable
                                 records.setup(collection.total_entries, variables)
                                 records
                               end
      end

    end
  end
end
