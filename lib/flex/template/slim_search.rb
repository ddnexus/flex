module Flex
  class Template
    class SlimSearch < Search

      # removes the fields param (no _source returned)
      # the result.loaded_collection, will load the records from the db
      def self.variables
        super.add(:params => {:fields => ''})
      end

    end
  end
end
