# Flex

Flex is the ultimate ruby client for [elasticsearch](http://elasticsearch.org). It is powerful, fast and efficient, easy to use and customize.

It covers ALL the elasticsearch API, and transparently integrates it with your app and its components, like `Rails`, `ActiveRecord`, `Mongoid`, `ActiveModel`, `will_paginate`, `kaminari`, `elasticsearch-mapper-attachments`, ...

It also implements and integrates very advanced features like chainable scopes, live-reindex, cross-model syncing, query fragment reuse, parent/child relationships, templating, self-documenting tools, detailed debugging, ...

## Quick Start

The Flex documentation is very complete and detailed, so starting from the right topic for you will save you time. Please, pick the starting point that better describes you below:

### For Tire Users

1. You may be interested to start from [Why you should use Flex rather than Tire](http://ddnexus.github.io/flex/doc/7-Tutorials/1-Flex-vs-Tire.html) that is a direct comparison between the two projects.

2. Depending on your elasticsearch knowledge you can read below the "Elasticsearch Beginner" or the "Elasticsearch Expert" starting point sections.

### For Flex 0.x Users

1. If you used an old flex version, please start with [How to migrate from flex 0.x](http://ddnexus.github.io/flex/doc/7-Tutorials/2-Migrate-from-0.x.html).

2. Depending on your elasticsearch knowledge you can read below the "Elasticsearch Beginner" or the "Elasticsearch Expert" sections.

### For Elasticsearch Beginners

1. You may want to start with the [Index and Search External Data](http://ddnexus.github.io/flex/doc/7-Tutorials/4-Index-and-Search-External-Data.md) tutorial, since it practically doesn't require any elasticsearch knowledge. It will show you how to build your own search application with just a few lines of code. You will crawl a site, extract its content and build a simple user interface to search it with elasticsearch.

2. Then you may want to read the [Usage Overview](http://ddnexus.github.io/flex/doc/1-Flex-Project/2-Usage-Overview.html) page. Follow the links from there in order to dig into the topics that interest you.

3. You will probably like the [flex-scopes](http://ddnexus.github.io/flex/doc/3-flex-scopes) that allows you to easy search, chain toghether and reuse searching scopes in pure ruby.

### For Elasticsearch Experts

1. Flex provides the full elasticsearch APIs as ready to use methods. Just take a look at the [API Metods](http://ddnexus.github.io/flex/doc/2-flex/2-API-Methods.html) page to appreciate its completeness.

2. Then you may want to read the [Usage Overview](http://ddnexus.github.io/flex/doc/1-Flex-Project/2-Usage-Overview.html) page. Follow the links from there in order to dig into the topics that interest you.

3. If you are used to create complex searching logic, you will certainly appreciate the [Templating System](http://ddnexus.github.io/flex/doc/2-flex/3-Templating) that gives you real power with great simplicity.

4. As an elasticsearch expert, you will certainly appreciate the [Live-Reindex](http://ddnexus.github.io/flex/doc/6-flex-admin/2-Live-Reindex.html) feature: it encapsulates the solution to a quite complex problem in just one method call.

## Links

* [Flex Project (Global Documentation)](http://ddnexus.github.io/flex/doc/)
* [flex Gem (Specific Documentation)](http://ddnexus.github.io/flex/doc/2-flex)
* [Issues](https://github.com/ddnexus/flex/issues)
* [Pull Requests](https://github.com/ddnexus/flex/pulls)

## Branches

The master branch reflects the last published gem. Then you may find a next-version branch (named after the version string), with the commits that will be merged in master just before publishing the next gem version. The next-version branch may get rebased or force pushed.

## Credits

Special thanks for their sponsorship to [Escalate Media](http://www.escalatemedia.com) and [Barquin International](http://www.barquin.com).

## Copyright

Copyright (c) 2012-2013 by [Domizio Demichelis](mailto://dd.nexus@gmail.com)<br>
See [LICENSE](https://github.com/ddnexus/flex/blob/master/LICENSE) for details.
