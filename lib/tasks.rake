require 'flex'

env   = defined?(Rails) ? :environment : []

namespace :flex do

  # deprecated tasks
  task(:create_indices => env) do
    Flex::Deprecation.warn 'flex:create_indices', 'flex:index:create', nil
    Flex::Tasks.new.create_indices
  end
  task(:delete_indices => env) do
    Flex::Deprecation.warn 'flex:delete_indices', 'flex:index:delete', nil
    Flex::Tasks.new.delete_indices
  end

  namespace :index do

    desc 'creates index/indices from the Flex::Configuration.config_file file'
    task(:create => env) { Flex::Tasks.new.create_indices }

    desc 'destroys index/indices in the Flex::Configuration.config_file file'
    task(:delete => env) { Flex::Tasks.new.delete_indices }

  end


end
