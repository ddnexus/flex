require 'flex'
require 'flex-admin'

env = defined?(Rails) ? :environment : []

namespace :flex do
  namespace :admin do

    desc 'Dumps the data from one or more ElasticSearch indices to a file'
    task(:dump => env) { Flex::Admin::Tasks.new.dump_to_file }

    desc 'Loads a dumpfile into ElasticSearch'
    task(:load => env) { Flex::Admin::Tasks.new.load_from_file }

  end

end
