# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/changelog_generator/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-changelog_generator'
  spec.version       = Fastlane::ChangelogGenerator::VERSION
  spec.author        = %q{Fernando Saragoca}
  spec.email         = %q{fsaragoca@me.com}

  spec.summary       = %q{Generates changelogs based on merged pull requests & tags}
  spec.homepage      = "https://github.com/fsaragoca/fastlane-plugin-changelog_generator"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'octokit', '~> 4.2'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 1.111.0'
end
