require 'prompter'

class Flex::SetupGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  def self.banner
    "rails generate flex:setup"
  end

  def ask_base_name
    @module_name   = Prompter.ask('Please, enter a class name for your Search class. Choose a name not defined in your app.',
                                  :default => 'FlexSearch', :hint => '[<enter>=FlexSearch]')
    @extender_name = "#{@module_name}Extender"
  end

  def add_config_flex_file
    template 'flex_config.yml', Rails.root.join('config', 'flex.yml')
  end

  def create_initializer_file
    template 'flex_initializer.rb.erb', Rails.root.join('config', 'initializers', 'flex.rb')
  end

  def create_flex_dir
    template 'flex_dir/es.rb.erb',          Rails.root.join('app', 'flex', "#{@module_name.underscore}.rb")
    template 'flex_dir/es.yml.erb',         Rails.root.join('app', 'flex', "#{@module_name.underscore}.yml")
    template 'flex_dir/es_extender.rb.erb', Rails.root.join('app', 'flex', "#{@extender_name.underscore}.rb")
  end


  def show_setup_message
    Prompter.say <<-text, :style => :green

    Setup done!

    During prototyping, remember also:

      1. each time you include a new Flex::ModelIndexer
         you should add its name to the config.flex_model in "config/initializers/flex.rb"

      2. each time you include a new Flex::ActiveModel
         you should add its name to the config.flex_active_model in "config/initializers/flex.rb"

      3. each time you add/change a flex.parent relation you should reindex

    The complete documentation is available at https://github.com/ddnexus/flex-doc/doc
    If you have any problem with Flex, please report the issue at https://github.com/ddnexus/flex/issues.
    text
  end

end

