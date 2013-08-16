# flex-models

[![Gem Version](https://badge.fury.io/rb/flex-models.png)](http://badge.fury.io/rb/flex-models)

Transparently integrates your models with one or more elasticsearch indices:

* Automatic integration with your `ActiveRecord` and `Mongoid` models
* Direct management of indices throught `ActiveModel`
   * Validations and callbacks
   * Typecasting
   * Attribute defaults
   * Persistent storage with optimistic lock update
   * integration with the `elasticsearch-mapper-attachment` plugin
   * finders, chainable scopes etc. {% see 4.3 %}
* Automatic generation of elasticsearch mappings based on your models
* Parent/Child Relationships
* Bulk import
* Real-time indexing and search capabilities

## Links

- __Gem-Specific Documentation__
  - [flex-models](http://ddnexus.github.io/flex/doc/4-flex-models)

## Credits

Special thanks for their sponsorship to [Escalate Media](http://www.escalatemedia.com) and [Barquin International](http://www.barquin.com).

## Copyright

Copyright (c) 2012-2013 by [Domizio Demichelis](mailto://dd.nexus@gmail.com)<br>
See [LICENSE](https://github.com/ddnexus/flex/blob/master/flex-models/LICENSE) for details.
