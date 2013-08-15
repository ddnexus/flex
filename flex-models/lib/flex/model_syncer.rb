module Flex
  module ModelSyncer

    def self.included(base)
      base.class_eval do
        @flex ||= ClassProxy::Base.new(base)
        @flex.extend(ClassProxy::ModelSyncer)
        def self.flex; @flex end
      end
    end

    def flex
      @flex ||= InstanceProxy::ModelSyncer.new(self)
    end

  end
end
