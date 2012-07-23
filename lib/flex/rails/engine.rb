module Flex
  module Rails
    class Engine < ::Rails::Engine

      ActiveSupport.on_load(:before_configuration) do
        Flex::Configuration.configure do |c|
          c.variables[:index] = [self.class.name.split('::').first.underscore, ::Rails.env].join('_')
          c.config_file       = ::Rails.root.join('config', 'flex.yml').to_s
          c.flex_dir          = ::Rails.root.join('app', 'flex').to_s
        end
      end

      ActiveSupport.on_load(:after_initialize) do
        Helper.after_initialize
      end

      config.to_prepare do
        Flex.reload!
      end

    end
  end
end
