# QueryRelation

[![Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ManageIQ/query_relation?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Provides an ActiveRecord::Relation-like DSL to non-SQL backends

[![Gem Version](https://badge.fury.io/rb/query_relation.svg)](http://badge.fury.io/query_relation)
[![Build Status](https://travis-ci.com/ManageIQ/query_relation.svg)](https://travis-ci.com/ManageIQ/query_relation)
[![Code Climate](https://codeclimate.com/github/ManageIQ/query_relation/badges/gpa.svg)](https://codeclimate.com/github/ManageIQ/query_relation)
[![Codacy](https://api.codacy.com/project/badge/grade/9ffce48ccb924020ae8f9e698048e9a4)](https://www.codacy.com/app/ManageIQ/query_relation)
[![Coverage Status](https://coveralls.io/repos/ManageIQ/query_relation/badge.svg?branch=master&service=github)](https://coveralls.io/github/ManageIQ/query_relation?branch=master)
[![Security](https://hakiri.io/github/ManageIQ/query_relation/master.svg)](https://hakiri.io/github/ManageIQ/query_relation/master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'query_relation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install query_relation

## Usage

The `QueryRelation` class is provided to encapsulate building a relation.  It is
a chainable interface, upon which query methods can be called, and final
execution is delayed until the last possible moment.  It can be instantiated
directly, but the more common way to get access to one is to mixin the
`QueryRelation::Queryable` module into your collection.

`QueryRelation::Queryable` expects a method named `search` to be implemented by
the mixee.  `search` should be written to take two parameters

- `mode`: one of `first`, `last`, or `all`
- `options`: a Hash containing the choices that were made by the caller.  It
  will contain the keys `:where`, `:select`, `:limit`, `:offset`, `:order`,
  `group`, `:includes`, and/or `:references`

The `search` method should be written to process this set of options and return
an Array of the selection.  It can use the options and mode in any way it sees
fit to optimally return the requested values.

### Example

Here's a simple example that supports limit and offset over a simple collection
to give an idea of how one might write a `search` method.

```ruby
class MyCollection
  include QueryRelation::Queryable

  private

  THE_COLLECTION = [1, 2, 3, 4].freeze

  def search(mode, options)
    collection = filter_collection_by_options(options)

    case mode
    when :first then collection.first
    when :last  then collection.last
    when :all   then collection
    end
  end

  def filter_collection_by_options(options)
    collection = THE_COLLECTION
    collection = collection.drop(options[:offset]) if options[:offset]
    collection = collection.take(options[:limit]) if options[:limit]
    collection
  end
end

MyCollection.new.all.to_a
# => [1, 2, 3, 4]
MyCollection.new.limit(2).to_a
# => [1, 2]
MyCollection.new.limit(1).offset(2).to_a
# => [3]
MyCollection.new.first
# => 1
MyCollection.new.last
# => 4
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ManageIQ/query_relation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).
