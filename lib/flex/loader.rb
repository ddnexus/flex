module Flex
  module Loader

    extend self
    attr_accessor :host_classes
    @host_classes = []

    def self.included(base)
      base.class_eval do
        Flex::Loader.host_classes |= [base]
        @flex ||= ClassProxy::Loader.new(base)
        def self.flex; @flex end
        def self.flex_result(result); result end
      end
    end

  end
end

