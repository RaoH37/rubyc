# frozen_string_literal: true

require_relative 'lib/rubyc'

Gem::Specification.new do |spec|
  spec.name = 'rubyc'
  spec.version = Rubyc.version
  spec.date = `date '+%Y-%m-%d'`
  spec.authors = ['Maxime Désécot']
  spec.email = ['maxime.desecot@gmail.com']

  spec.summary = 'Tool to generate or load byte-coded Ruby project'
  spec.homepage = 'https://github.com/RaoH37/rubyc'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.executables = ['rubyc']
  spec.require_paths = ['lib', 'bin']
end
