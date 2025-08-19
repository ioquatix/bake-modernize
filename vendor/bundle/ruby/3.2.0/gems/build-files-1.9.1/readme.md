# Build::Files

Build::Files is a set of idiomatic classes for dealing with paths and monitoring directories. File paths are represented with both root and relative parts which makes copying directory structures intuitive.

[![Development Status](/workflows/Test/badge.svg)](/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

    gem 'build-files'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install build-files

## Usage

The basic structure is the `Path`. Paths are stored with a root and relative part. By default, if no root is specified, it is the `dirname` part.

    require 'build/files'
    
    path = Build::Files::Path("/foo/bar/baz")
    => "/foo/bar"/"baz"
    
    > path.root
    => "/foo/bar"
    > path.relative_path
    => "baz"

Paths can be coerced to strings and thus are suitable arguments to `exec`/`system` functions.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
