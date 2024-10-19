# Rubyc

It's a tool for transforming a ruby project into a byte-coded version.

Rubyc allows you to generate a new version of your Ruby files and load them into other projects.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rubyc

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rubyc

## Usage

After installation, Rubyc provides a `rubyc` executable to generate or run a byte-coded Ruby project.

```bash
rubyc -h
Usage: rubyc v1.0.0 [options]
        --load PATH                  byte file to load
        --generate PATH              file or directory to compile
        --record-path PATH           directory to record compiled file
```

### Generate a byte-coded version of a Ruby project

```bash
rubyc --generate /path/of/the/project
```

### Run a byte-coded project

```bash
rubyc --load /path/of/the/byte-coded/project
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RaoH37/rubyc.
