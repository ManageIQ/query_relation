# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'query_relation/version'

Gem::Specification.new do |spec|
  spec.name          = "query_relation"
  spec.version       = QueryRelation::VERSION
  spec.authors       = ["Keenan Brock", "Jason Frey"]
  spec.email         = ["kbrock@redhat.com", "jfrey@redhat.com"]

  spec.summary       = %q{Provides an ActiveRecord::Relation-like DSL to non-SQL backends}
  spec.description   = %q{Provides an ActiveRecord::Relation-like DSL to non-SQL backends}
  spec.homepage      = "https://github.com/ManageIQ/query_relation"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "activesupport"
  spec.add_dependency "more_core_extensions"
end
