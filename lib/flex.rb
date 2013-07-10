require 'dye'
require 'yaml'
require 'ostruct'
require 'erb'
require 'multi_json'
require 'flex/logger'
require 'flex/errors'
require 'flex/utils'

require 'flex/struct/prunable'
require 'flex/struct/symbolize'
require 'flex/struct/hash'
require 'flex/struct/array'

require 'flex/variables'

require 'flex/result'
require 'flex/struct/paginable'
require 'flex/result/document'
require 'flex/result/search'
require 'flex/result/multi_get'
require 'flex/result/bulk'

require 'flex/template/common'
require 'flex/template/partial'
require 'flex/template/logger'
require 'flex/template'
require 'flex/template/search'
require 'flex/template/slim_search'
require 'flex/template/tags'

require 'flex/class_proxy/base'
require 'flex/class_proxy/templates/search'
require 'flex/class_proxy/templates/doc'

require 'flex/class_proxy/templates'

require 'flex/templates'

require 'flex/http_clients/base'
require 'flex/http_clients/loader'
require 'flex/configuration'
require 'flex/utility_methods'

require 'progressbar'
require 'flex/prog_bar'
require 'flex/deprecation'

require 'flex/api_stubs'

module Flex

  VERSION   = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  LIB_PATHS = [ File.dirname(__FILE__) ]


  include ApiStubs

  include Templates
  flex.load_source File.expand_path('../flex/api_templates/core_api.yml'   , __FILE__)
  flex.load_source File.expand_path('../flex/api_templates/indices_api.yml', __FILE__)
  flex.load_source File.expand_path('../flex/api_templates/cluster_api.yml', __FILE__)

  extend self
  extend UtilityMethods

  def reload!
    flex.variables.deep_merge! Conf.variables
    Templates.contexts.each {|c| c.flex.reload!}
    true
  end

  def doc(*args)
    flex.doc(*args)
  end

  def scan_search(*args, &block)
    flex.scan_search(*args, &block)
  end

  def scan_all(*args, &block)
    flex.scan_search(:match_all, *args) do |raw_result|
      batch = raw_result['hits']['hits']
      block.call(batch)
    end
  end


end
