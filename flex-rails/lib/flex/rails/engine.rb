module Flex
  module Rails
    class Engine < ::Rails::Engine

      ActiveSupport.on_load(:before_configuration) do
        config.flex = Conf
        config.flex.variables[:index] = [self.class.name.split('::').first.underscore, ::Rails.env].join('_')
        config.flex.config_file       = ::Rails.root.join('config', 'flex.yml').to_s
        config.flex.flex_dir          = ::Rails.root.join('app', 'flex').to_s
        config.flex.logger            = Logger.new(STDOUT)
        config.flex.logger.level      = ::Logger::DEBUG if ::Rails.env.development?
        config.flex.result_extenders |= [ Flex::Result::RailsHelper ]
      end

      ActiveSupport.on_load(:after_initialize) do
        Helper.after_initialize
      end

      rake_tasks do
        Flex::LIB_PATHS.each do |path|
          task_path = "#{path}/tasks.rake"
          load task_path if File.file?(task_path)
        end
      end

      console do
        config.flex.logger.log_to_rails_logger = false
        config.flex.logger.log_to_stderr       = true
        config.flex.logger.debug_variables     = false
        config.flex.logger.debug_result        = false
      end

      config.to_prepare do
        Flex.reload!
      end

    end
  end
end
