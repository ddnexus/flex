require 'prompter'

class Flex::SetupGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  def self.banner
    "rails generate flex:setup"
  end

  def ask_base_name
    @class_name = Prompter.ask('Please, enter a class name for your Search class. Choose a name not defined in your app.',
                               :default => 'FlexSearch', :hint => '[<enter>=FlexSearch]')
    @extender_name = "#{@class_name}Extender"
  end

  def add_config_flex_file
    template 'flex_config.yml', Rails.root.join('config', 'flex.yml')
  end

  def create_initializer_file
    template 'flex_initializer.rb.erb', Rails.root.join('config', 'initializers', 'flex.rb')
  end

  def create_flex_dir
    template 'flex_dir/es.rb.erb',          Rails.root.join('app', 'flex', "#{@class_name.underscore}.rb")
    template 'flex_dir/es.yml.erb',         Rails.root.join('app', 'flex', "#{@class_name.underscore}.yml")
    template 'flex_dir/es_extender.rb.erb', Rails.root.join('app', 'flex', "#{@extender_name.underscore}.rb")
  end


  def show_setup_message
    say <<-text, :style => :green

    Setup done!

    During prototyping, remember also:

    1. each time you add a `Flex::Model` you should add its name to the "config/initializers/flex.rb"
    2. each time you add/change a flex.parent relation you should reindex your DB(s) with rake `flex:import FORCE=true`

    The complete documentation is available at https://github.com/ddnexus/flex/wiki
    If you have any problem with Flex, please report the issue at https://github.com/ddnexus/flex/issues.
    text
  end

end

