require 'flex'
require 'flex/tasks'

env   = defined?(Rails) ? :environment : []

namespace :flex do

  desc 'imports from an ActiveRecord or Mongoid models'
  task(:import => env) {  Flex::Tasks.new.import_models }

  # deprecated tasks
  task(:create_indices => env) { Flex::Tasks.new.create_indices }
  task(:delete_indices => env) { Flex::Tasks.new.delete_indices }

  namespace :index do

    desc 'creates index/indices from the Flex::Configuration.config_file file'
    task(:create => env) { Flex::Tasks.new.create_indices }

    desc 'destroys index/indices in the Flex::Configuration.config_file file'
    task(:delete => env) { Flex::Tasks.new.delete_indices }

  end


end
