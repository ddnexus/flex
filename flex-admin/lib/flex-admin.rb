require 'flex'
require 'flex/admin'
require 'flex/live_reindex_admin'

Flex::LIB_PATHS << File.dirname(__FILE__)

Flex::Conf.redis = $redis || defined?(::Redis) && ::Redis.current
