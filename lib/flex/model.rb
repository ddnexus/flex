module Flex
  module Model

    def self.included(base)
      base.class_eval do
        class << self; attr_reader :flex end
        @flex ||= Flex::Model::ClassProxy.new(base)
      end
    end

    def flex
      @flex ||= InstanceProxy.new(self)
    end

    def flex_source
      to_hash.reject {|k| k.to_s =~ /^_*id$/}.to_json
    end

    def flex_indexable?
      true
    end

  end
end
