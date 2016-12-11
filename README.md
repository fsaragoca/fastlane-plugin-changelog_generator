# changelog_generator plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-changelog_generator)
[![Twitter: @fsaragoca](https://img.shields.io/badge/contact-@fsaragoca-blue.svg?style=flat)](https://twitter.com/fsaragoca)

[![CircleCI](https://circleci.com/gh/fsaragoca/fastlane-plugin-changelog_generator.svg?style=svg)](https://circleci.com/gh/fsaragoca/fastlane-plugin-changelog_generator)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-changelog_generator`, add it to your project by running:

```bash
fastlane add_plugin changelog_generator
```

## About changelog_generator

|                   |  changelog_generator  |
|-------------------|-----------------------|
| :book:            | Generate a [changelog](https://github.com/fsaragoca/fastlane-plugin-changelog_generator/blob/master/CHANGELOG.md) based on git tags & pull requests
| :pencil2:         | Flexible configuration using a fully customisable [template file](https://github.com/fsaragoca/fastlane-plugin-changelog_generator/blob/master/fastlane/changelog_template.erb)
| :page_with_curl:  | Full access to [pull request information](https://developer.github.com/v3/pulls/#get-a-single-pull-request) directly from template

## Example

This project automatically generates [`CHANGELOG.md`](CHANGELOG.md) when pushing changes to `master`, check out [`Fastfile`](fastlane/Fastfile) and [`changelog_template.erb`](fastlane/changelog_template.erb) for project setup. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Actions

### :book: generate_changelog

```
changelog = generate_changelog(
  github_project: 'fsaragoca/fastlane-plugin-changelog_generator',
  github_api_token: 'GITHUB_API_TOKEN',
  base_branch: 'master',
  template_path: 'fastlane/changelog_template.erb',
  template: 'YOUR_ERB_TEMPLATE', # Must provide either template or template_path
  tags: ['v0.2.0', 'v0.1.0'], # Optional, defaults to all git tags
  max_number_of_tags: 10, # Optional, limits number of tags when using all git tags
  include_unreleased_section: true, # Optional, defaults to false
  output_path: 'CHANGELOG.md' # Optional
)
```

### :ship: generate_release_changelog

```
v2_changelog = generate_release_changelog(
  github_project: 'fsaragoca/fastlane-plugin-changelog_generator',
  github_api_token: 'GITHUB_API_TOKEN',
  base_branch: 'master',
  template_path: 'fastlane/changelog_template.erb',
  template: 'YOUR_ERB_TEMPLATE', # Must provide either template or template_path
  tag_a: 'v0.2.0',
  tag_b: 'v0.1.0', # Optional, will be prompted if not provided
  skip_tag_b: true, # Optional, defaults to false
  output_path: 'RELEASE_0.2.0.md' # Optional
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
