require 'flex/tasks'

env = defined?(Rails) ? :environment : []

namespace :flex do

  desc 'imports from an ActiveRecord or Mongoid models'
  task(:import => env) { Flex::Tasks.import_models }

  desc 'creates indices from the Flex::Configuration.config_file file'
  task(:create_indices => env) { Flex::Tasks.create_indices }

  desc 'destroys indices in the Flex::Configuration.config_file file'
  task(:delete_indices => env) { Flex::Tasks.delete_indices }

end
