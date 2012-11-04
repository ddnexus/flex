module Flex
  module ClassProxy
    class Model < Base

      include Modules::Model

      def initialize(base)
        super
        variables.add :index => Configuration.variables[:index],
                      :type  => Manager.class_name_to_type(host_class.name)
      end

    end
  end
end
