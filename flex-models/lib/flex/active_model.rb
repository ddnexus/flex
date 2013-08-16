module Flex
  module ActiveModel

    attr_reader :_version, :_id, :highlight
    alias_method :id, :_id

    def self.included(base)
      base.class_eval do
        @flex ||= ClassProxy::Base.new(base)
        @flex.extend(ClassProxy::ModelSyncer)
        @flex.extend(ClassProxy::ModelIndexer).init
        @flex.extend(ClassProxy::ActiveModel).init :params => {:version => true}
        def self.flex; @flex end
        flex.synced = [self]

        include Scopes
        include ActiveAttr::Model

        extend  ::ActiveModel::Callbacks
        define_model_callbacks :create, :update, :save, :destroy

        include Storage::InstanceMethods
        extend  Storage::ClassMethods
        include Inspection
        extend  Timestamps
        extend  Attachment
      end
    end

    def flex
      @flex ||= InstanceProxy::ActiveModel.new(self)
    end

    def flex_source
      attributes
    end

    def flex_indexable?
      true
    end

    def method_missing(meth, *args, &block)
      raw_document.respond_to?(meth) ? raw_document.send(meth) : super
    end

  end
end
