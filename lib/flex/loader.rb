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
        def self.template_methods; flex.templates.keys end
        extend FlexResult unless respond_to?(:flex_result)
        eval "extend module #{context}::FlexTemplateMethods; self end"
      end
    end

  end
end
