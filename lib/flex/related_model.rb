module Flex
  module RelatedModel

    def self.included(base)
      base.class_eval do
        class << self; attr_reader :flex end
        @flex ||= Flex::RelatedModel::ClassProxy.new(base)
      end
    end

    def flex
      @flex ||= InstanceProxy.new(self)
    end

  end
end
