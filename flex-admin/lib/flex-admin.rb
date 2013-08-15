require 'flex'
require 'flex/admin'
require 'flex/live_reindex'

Flex::LIB_PATHS << File.dirname(__FILE__)

Flex::Conf.redis = $redis || defined?(::Redis) && ::Redis.current
