module Flex
  module Loader

    extend self
    attr_accessor :host_classes
    @host_classes = []

    def self.included(host_class)
      host_class.class_eval do
        Flex::Loader.host_classes |= [host_class]
        @flex ||= ClassProxy::Base.new(host_class)
        @flex.extend(ClassProxy::Loader).init
        def self.flex; @flex end
        extend FlexResult unless respond_to?(:flex_result)
      end
    end

  end
end

