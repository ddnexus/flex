module Flex
  module RelatedModel

    def self.included(base)
      base.class_eval do
        @flex ||= ClassProxy::Base.new(base)
        @flex.extend(ClassProxy::RelatedModel)
        def self.flex; @flex end
      end
    end

    def flex
      @flex ||= InstanceProxy::RelatedModel.new(self)
    end

  end
end
