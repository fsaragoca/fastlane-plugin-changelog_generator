module Fastlane
  module Actions
    class GenerateReleaseChangelogAction < Action
      def self.run(params)
        tag_a = params[:tag_a] || prompt_tag("Please enter first tag: ")
        tag_b = params[:tag_b]
        if tag_b.nil? && params[:skip_tag_b].nil?
          tag_b = prompt_tag("Please enter second tag: ", [tag_a], true)
        end

        labels, pull_requests = other_action.fetch_github_labels(github_project: params[:github_project],
                                                                 base_branch: params[:base_branch],
                                                                 github_api_token: params[:github_api_token])

        release = Helper::ChangelogGeneratorRelease.new(labels, pull_requests, tag_b, tag_a)
        Helper::ChangelogGeneratorRender.new([release], labels, params).to_markdown
      end

      def self.prompt_tag(message = '', excluded_tags = [], allow_none = false)
        no_tag_text = 'No tag'

        available_tags = Helper::ChangelogGeneratorHelper.git_tags
        available_tags.reject! { |tag| excluded_tags.include?(tag) }
        available_tags << no_tag_text if allow_none

        if allow_none && available_tags.count == 1
          UI.important("Skiping second tag because there are no tags available.")
          return nil
        end

        tag = UI.select(message, available_tags)
        tag = nil if tag == no_tag_text
        tag
      end

      def self.description
        "Changelog generation based on merged pull requests & tags, filtered by one or two tags"
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
          FastlaneCore::ConfigItem.new(key: :tag_a,
                                       env_name: 'GENERATE_CHANGELOG_TAG_A',
                                       description: 'Tag to filter pull requests',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :tag_b,
                                       env_name: 'GENERATE_CHANGELOG_TAG_B',
                                       description: 'Tag to filter pull requests',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :skip_tag_b,
                                       env_name: 'GENERATE_CHANGELOG_SKIP_TAG_B',
                                       description: 'Skip second tag',
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
