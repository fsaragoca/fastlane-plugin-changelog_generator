module Fastlane
  module Actions
    class GenerateChangelogAction < Action
      def self.run(params)
        labels, pull_requests = other_action.fetch_github_labels(github_project: params[:github_project],
                                                                 base_branch: params[:base_branch],
                                                                 github_api_token: params[:github_api_token])

        tag_limit = params[:max_number_of_tags]
        tags = params[:tags] || other_action.git_tags(limit: tag_limit)
        releases = []

        # Unreleased section
        if params[:include_unreleased_section]
          unreleased_section = Helper::ChangelogGeneratorRelease.new(labels, pull_requests, tags.first, nil)
          releases << unreleased_section if unreleased_section.data.count > 0
        end

        # Between tags sections
        tags.each_with_index do |tag, idx|
          if idx != 0
            previous_tag = tags[idx - 1]
            releases << Helper::ChangelogGeneratorRelease.new(labels, pull_requests, previous_tag, tag)
          end
        end

        # Last section
        if tags.count > 0 && params[:tags].nil? && (tag_limit.nil? || tags.count < tag_limit)
          releases << Helper::ChangelogGeneratorRelease.new(labels, pull_requests, nil, tags.last)
        end

        Helper::ChangelogGeneratorRender.new(releases, labels, params).to_markdown
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
          FastlaneCore::ConfigItem.new(key: :github_api_token,
                                       env_name: 'GENERATE_CHANGELOG_GITHUB_API_TOKEN',
                                       description: 'API token to access GitHub API',
                                       default_value: ENV["GITHUB_API_TOKEN"]),
          FastlaneCore::ConfigItem.new(key: :base_branch,
                                       env_name: 'GENERATE_CHANGELOG_BASE_BRANCH',
                                       description: 'Base branch for pull requests'),
          FastlaneCore::ConfigItem.new(key: :template,
                                       env_name: 'GENERATE_CHANGELOG_TEMPLATE',
                                       description: 'Template for generating changelog',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :template_path,
                                       env_name: 'GENERATE_CHANGELOG_TEMPLATE_PATH',
                                       description: 'Contents of path will override `template` param',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :tags,
                                       env_name: 'GENERATE_CHANGELOG_TAGS',
                                       description: 'Tags to generate changelog',
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
