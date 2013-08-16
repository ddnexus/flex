require 'flex'
require 'flex-models'
require 'rails'
require 'flex/result/rails_helper'
require 'flex/rails/helper'
require 'flex/rails/logger'

Flex::LIB_PATHS << File.dirname(__FILE__)

if ::Rails.respond_to?(:version) && ::Rails.version.to_i >= 3
  require 'flex/rails/engine'
else
  Flex::Conf.configure do |c|
    c.config_file       = "#{RAILS_ROOT}/config/flex.yml"
    c.flex_dir          = "#{RAILS_ROOT}app/flex"
    c.logger            = Logger.new(STDOUT)
    c.logger.level      = ::Logger::DEBUG if RAILS_ENV == 'development'
    c.result_extenders |= [ Flex::Result::RailsHelper ]
  end
end
