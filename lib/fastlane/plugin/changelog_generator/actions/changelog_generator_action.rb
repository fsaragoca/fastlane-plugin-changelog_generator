module Fastlane
  module Actions
    class GenerateChangelogAction < Action
      def self.run(params)
        Actions.verify_gem!('octokit')

        filter_by_tag = params[:filter_by_tag]
        tag_from = nil
        tag_to = nil

        if filter_by_tag.nil?
          filter_by_tag = UI.confirm("Filter changelog by a tag range?")
        end

        if filter_by_tag
          tag_from = params[:from_tag] || prompt_tag("Please enter start tag: ")
          tag_to = params[:to_tag] || prompt_tag("Please enter final tag: ", [tag_from])
        end

        labels, pull_requests = Helper::ChangelogGeneratorFetcher.fetch_labels(params[:github_project],
                                                                               params[:base_branch],
                                                                               params[:github_access_token])

        releases = []
        if filter_by_tag
          releases << Helper::ChangelogGeneratorRelease.new(labels, pull_requests, tag_from, tag_to)
        else
          tags = `git tag --sort=taggerdate`.split("\n").reverse
          tags = tags.take(params[:max_number_of_tags]) if params[:max_number_of_tags]
          previous_tag = nil

          if params[:include_unreleased_section]
            unreleased_section = Helper::ChangelogGeneratorRelease.new(labels, pull_requests, tags.first, nil)
            releases << unreleased_section if unreleased_section.data.count > 0
          end

          tags.each do |tag|
            releases << Helper::ChangelogGeneratorRelease.new(labels, pull_requests, previous_tag, tag) if previous_tag
            previous_tag = tag
          end

          if tags.count > 0 && (params[:max_number_of_tags].nil? || tags.count < params[:max_number_of_tags])
            releases << Helper::ChangelogGeneratorRelease.new(labels, pull_requests, nil, tags.last)
          end
        end

        if params[:template_path]
          params[:template] = File.read(params[:template_path])
        end

        render = Helper::ChangelogGeneratorRender.new(releases, labels, params)
        changelog = render.to_markdown
        File.write(params[:output_path], changelog) if params[:output_path]
        changelog
      end

      def self.description
        "Changelog generation based on merged pull requests & tags"
      end

      def self.authors
        ["Fernando Saragoca"]
      end

      def self.return_value
        "Generated changelog"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :github_project,
                                       env_name: 'GENERATE_CHANGELOG_GITHUB_PROJECT',
                                       description: 'GitHub project name, including organization'),
          FastlaneCore::ConfigItem.new(key: :github_access_token,
                                       env_name: 'GENERATE_CHANGELOG_GITHUB_ACESS_TOKEN',
                                       description: 'Access token to access GitHub API'),
          FastlaneCore::ConfigItem.new(key: :base_branch,
                                       env_name: 'GENERATE_CHANGELOG_BASE_BRANCH',
                                       description: 'Base branch for pull requests'),
          FastlaneCore::ConfigItem.new(key: :template,
                                       env_name: 'GENERATE_CHANGELOG_TEMPLATE',
                                       description: 'Template for generating changelog'),
          FastlaneCore::ConfigItem.new(key: :template_path,
                                       env_name: 'GENERATE_CHANGELOG_TEMPLATE_PATH',
                                       description: 'Contents of path will override `template` param',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :from_tag,
                                       env_name: 'GENERATE_CHANGELOG_FROM_TAG',
                                       description: 'Tag to filter pull requests',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :to_tag,
                                       env_name: 'GENERATE_CHANGELOG_TO_TAG',
                                       description: 'Tag to filter pull requests',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :filter_by_tag,
                                       env_name: 'GENERATE_CHANGELOG_FILTER_BY_TAG',
                                       description: 'If yes, will generate changelog for specified tag range',
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :max_number_of_tags,
                                       env_name: 'GENERATE_CHANGELOG_MAX_NUMBER_OF_TAGS',
                                       description: 'Number of tags to generate changelog when not filtering by tag',
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :include_unreleased_section,
                                       env_name: 'GENERATE_CHANGELOG_INCLUDE_UNRELEASED_SECTION',
                                       description: 'Includes an unreleased section',
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                       env_name: 'GENERATE_CHANGELOG_OUTPUT_PATH',
                                       description: 'If set, will automatically write changelog to output path',
                                       optional: true)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
