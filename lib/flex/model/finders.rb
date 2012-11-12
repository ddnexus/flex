module Flex
  module Model
    module Finders

      class Error < StandardError; end

      def self.included(model)
        model.class_eval do
          raise Error, "#{model.name} is not a Flex::Model nor a Flex::StoredModel" \
                unless include?(Flex::Model) || include?(Flex::StoredModel)

          # creates a proxy module for the model
          module_eval <<-ruby
            module FinderProxy
              extend self
              extend FinderMethods
              # delegates to the model
              Utils.define_delegation :to  => #{model.name},
                                      :in  => self,
                                      :by  => :module_eval,
                                      :for => [:flex, :flex_result]
            end
          ruby

          # delegates to the proxy
          Utils.define_delegation :to  => "#{model.name}::FinderProxy",
                                  :in  => (include?(Flex::StoredModel) ? self : flex),
                                  :by  => :instance_eval,
                                  :for => Scoped::METHODS + FinderMethods::METHODS
        end
      end

    end
  end
end

