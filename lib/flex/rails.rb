require 'flex'
require 'rails'
require 'flex/rails/helper'

if ::Rails.respond_to?(:version) && ::Rails.version.to_i >= 3
  require 'flex/rails/engine'
else
  Flex::Configuration.configure do |c|
    c.config_file = ::Rails.root.join('config', 'flex.yml').to_s
    c.flex_dir    = ::Rails.root.join('app', 'flex').to_s
    c.debug       = ::Rails.env.development?
  end
end
