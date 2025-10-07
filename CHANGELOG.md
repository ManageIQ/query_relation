# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.2.0] - 2025-10-07
### Fixed
- `Model#pluck` now passes `:select` [#34](https://github.com/ManageIQ/query_relation/pull/34)

### Added
- Added support for Ruby 2.5-3.4 [#44](https://github.com/ManageIQ/query_relation/pull/44) and others
- Support for `Model.to_a` [#34](https://github.com/ManageIQ/query_relation/pull/34)
- Backwards compatibility between references/includes and eager_load/preload [#43](https://github.com/ManageIQ/query_relation/pull/43)

### Changed
- Dropped dependencies: more_core_extensions and active_support. [#31](https://github.com/ManageIQ/query_relation/pull/31)

## [0.1.1] - 2016-11-17
### Added
- Add CHANGELOG.md
- Update README with usage instructions.

[Unreleased]: https://github.com/ManageIQ/query_relation/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/ManageIQ/query_relation/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/ManageIQ/query_relation/compare/v0.1.0...v0.1.1
