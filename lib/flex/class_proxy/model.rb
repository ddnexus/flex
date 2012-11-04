module Flex
  module ClassProxy
    class Model < Base

      include Modules::Model
      include Modules::Loader
      include Modules::Scope

      def initialize(base)
        super
        variables.add :index => Configuration.variables[:index],
                      :type  => Manager.class_name_to_type(host_class.name)
        @sources   = []
        @templates = {}
        @partials  = {}
      end

    end
  end
end
