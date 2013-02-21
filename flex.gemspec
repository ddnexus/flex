require 'date'

Gem::Specification.new do |s|
  s.name                      = 'flex'
  s.summary                   = 'Ruby Client for ElasticSearch'
  s.description               = <<-desc
Flex is an innovative ruby client for ElasticSearch. With Flex your code will be clean, easy to write and read, and very short: "poetic-short". Flex is fast and efficient, easy to use and customize, and offers ActiveRecord, Mongoid and Rails integration.
  desc
  s.homepage                  = 'http://github.com/ddnexus/flex'
  s.authors                   = ['Domizio Demichelis']
  s.email                     = 'dd.nexus@gmail.com'
  s.extra_rdoc_files          = %w[README.md]
  s.require_paths             = %w[lib]
  s.files                     = `git ls-files -z`.split("\0")
  s.version                   = File.read(File.expand_path('../VERSION', __FILE__)).strip
  s.date                      = Date.today.to_s
  s.required_rubygems_version = '>= 1.3.6'
  s.rdoc_options              = %w[--charset=UTF-8]
  s.post_install_message      = <<EOM
________________________________________________________________________________

                             FLEX INSTALLATION NOTES
________________________________________________________________________________

In order to use Flex, a supported http-client must be installed on this system.

The suported http-client gems are "patron" and "rest-client".

You should install "patron" (a libcurl based gem developed in C) for best
performances, or install "rest-client" if you cannot use libcurl on your system.

As an alternative you could eventually develop your own http-client interface
and set the Flex::Configuration.http_client option.

________________________________________________________________________________
EOM
  s.add_runtime_dependency     'multi_json',  '>= 1.3.4',  '~> 1.6.1'
  s.add_runtime_dependency     'progressbar', '>= 0.11.0', '~> 0.12.0'
  s.add_runtime_dependency     'dye',         '~> 0.1.4'
  s.add_development_dependency 'patron',      '~> 0.4.18'
  s.add_development_dependency 'rest-client', '~> 1.6.7'
end
