module Flex
  module Loader

    extend self
    attr_accessor :contexts
    @contexts = []

    def self.included(context)
      context.class_eval do
        Flex::Loader.contexts |= [context]
        @flex ||= ClassProxy::Base.new(context)
        @flex.extend(ClassProxy::Loader).init
        def self.flex; @flex end
        extend FlexResult unless respond_to?(:flex_result)
      end
    end

  end
end

