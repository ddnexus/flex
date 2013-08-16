require 'date'
version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name                      = 'flex-scopes'
  s.summary                   = 'ActiveRecord-like chainable scopes and finders for Flex.'
  s.description               = 'Provides an easy to use ruby API to search elasticsearch with ActiveRecord-like chainable and mergeables scopes.'
  s.homepage                  = 'http://github.com/ddnexus/flex-scopes'
  s.authors                   = ["Domizio Demichelis"]
  s.email                     = 'dd.nexus@gmail.com'
  s.files                     = `git ls-files -z`.split("\0")
  s.version                   = version
  s.date                      = Date.today.to_s
  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options              = %w[--charset=UTF-8]
  s.license                   = 'MIT'

  s.add_runtime_dependency 'flex', version
end
