module Fastlane
  module Actions
    class FetchGithubLabelsAction < Action
      module SharedValues
        GENERATE_CHANGELOG_GITHUB_LABELS = :GENERATE_CHANGELOG_GITHUB_LABELS
        GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS = :GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS
      end

      def self.run(params)
        Actions.verify_gem!('octokit')

        labels = lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_LABELS]
        pull_requests = lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS]
        if labels && pull_requests
          UI.important "Skipping API call because labels & pull requests are cached"
          return labels, pull_requests
        end

        api_token = params[:github_api_token]
        base_branch = params[:base_branch]
        project = params[:github_project]

        labels, pull_requests = Helper::ChangelogGeneratorFetcher.fetch_labels(project,
                                                                               base_branch,
                                                                               api_token)
        lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_LABELS] = labels
        lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS] = pull_requests
        return labels, pull_requests
      end

      def output
        [
          ['GENERATE_CHANGELOG_GITHUB_LABELS', 'Fetched GitHub labels'],
          ['GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS', 'Fetched GitHub pull requests']
        ]
      end

      def self.description
        "Fetches GitHub for labels & merged pull requests"
      end

      def self.authors
        ["Fernando Saragoca"]
      end

      def self.return_value
        "A tuple with an array of labels & an array of pull requests"
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
                                       description: 'Base branch for pull requests')
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
