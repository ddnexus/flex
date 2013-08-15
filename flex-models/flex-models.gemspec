require 'date'
version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name                      = 'flex-models'
  s.summary                   = 'Transparently integrates your models with one or more elasticsearch indices.'
  s.description               = 'Provides ActiveRecord, Mongoid, ActiveModel and elasticsearch-mapper-attachment integrations, cross syncing, parent/child relationships, bulk-import, live-reindex of models, ...'
  s.homepage                  = 'http://github.com/ddnexus/flex-models'
  s.authors                   = ["Domizio Demichelis"]
  s.email                     = 'dd.nexus@gmail.com'
  s.files                     = `git ls-files -z`.split("\0")
  s.version                   = version
  s.date                      = Date.today.to_s
  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options              = %w[--charset=UTF-8]
  s.license                   = 'MIT'

  s.add_runtime_dependency 'flex',        version
  s.add_runtime_dependency 'flex-scopes', version

  s.add_runtime_dependency 'active_attr', '>= 0.6.0'
end
