require 'date'
version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name                      = 'flex'
  s.summary                   = 'The ultimate ruby client for elasticsearch'
  s.description               = <<-desc
Flex is the ultimate ruby client for elasticsearch. It is powerful, fast and efficient, easy to use and customize.

It covers ALL the elasticsearch API, and transparently integrates it with your app and its components, like Rails, ActiveRecord, Mongoid, ActiveModel, will_paginate, kaminari, elasticsearch-mapper-attachments, ...

It also implements and integrates very advanced features like chainable scopes, live-reindex, cross-model syncing, query fragment reuse, parent/child relationships, templating, self-documenting tools, detailed debugging, ...
  desc
  s.homepage                  = 'http://github.com/ddnexus/flex'
  s.authors                   = ['Domizio Demichelis']
  s.email                     = 'dd.nexus@gmail.com'
  s.require_paths             = %w[lib]
  s.files                     = `git ls-files -z`.split("\0")
  s.version                   = version
  s.date                      = Date.today.to_s
  s.required_rubygems_version = '>= 1.3.6'
  s.rdoc_options              = %w[--charset=UTF-8]
  s.license                   = 'MIT'
  s.post_install_message      = <<EOM
________________________________________________________________________________

                             FLEX INSTALLATION NOTES
________________________________________________________________________________

New Documentation:  http://ddnexus.github.io/flex

Upgrading Tutorial: http://ddnexus.github.io/flex/doc/7-Tutorials/2-Migrate-from-0.x.html

________________________________________________________________________________
EOM
  s.add_runtime_dependency     'multi_json',  '>= 1.3.4'
  s.add_runtime_dependency     'progressbar', '>= 0.11.0', '~> 0.12.0'
  s.add_runtime_dependency     'dye',         '~> 0.1.4'
end
