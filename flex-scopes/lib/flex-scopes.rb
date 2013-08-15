require 'flex'
require 'flex/scope/utils'
require 'flex/scope/filter_methods'
require 'flex/scope/vars_methods'
require 'flex/scope/query_methods'
require 'flex/scope'
require 'flex/scopes'
require 'flex/result/scope'

Flex::LIB_PATHS << File.dirname(__FILE__)

Flex::Conf.result_extenders |= [Flex::Result::Scope]
