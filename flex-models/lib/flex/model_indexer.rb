module Flex
  module ModelIndexer

    def self.included(base)
      base.class_eval do
        @flex ||= ClassProxy::Base.new(base)
        @flex.extend(ClassProxy::ModelSyncer)
        @flex.extend(ClassProxy::ModelIndexer).init
        def self.flex; @flex end
      end
    end

    def flex
      @flex ||= InstanceProxy::ModelIndexer.new(self)
    end

    def flex_source
      attributes.reject {|k| k.to_s =~ /^_*id$/}
    end

    def flex_indexable?
      true
    end

  end

end
