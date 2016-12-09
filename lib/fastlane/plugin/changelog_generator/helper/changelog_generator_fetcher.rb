require 'octokit'

module Fastlane
  module Helper
    class ChangelogGeneratorFetcher
      module SharedValues
        GENERATE_CHANGELOG_GITHUB_LABELS = :GENERATE_CHANGELOG_GITHUB_LABELS
        GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS = :GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS
      end

      def self.fetch_github_data(params, lane_context)
        Actions.verify_gem!('octokit')
        Octokit.auto_paginate = true

        labels = lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_LABELS]
        pull_requests = lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS]
        if labels && pull_requests
          UI.important "Skipping API call because labels & pull requests are cached"
          return labels, pull_requests
        end

        project = params[:github_project]
        base_branch = params[:base_branch]
        access_token = params[:github_api_token]

        issues_map = {}
        Octokit.issues(project, state: 'closed', access_token: access_token).each do |issue|
          issues_map[issue.number] = issue
        end

        # Fetch pull requests
        pull_requests = Octokit.pull_requests(project, state: 'closed', base: base_branch, access_token: access_token)

        # Remove pull requests not merged
        pull_requests.reject! do |pr|
          pr.merged_at.nil?
        end

        # Sort by merged_at
        pull_requests.sort_by!(&:merged_at)

        # Uniq labels
        labels = issues_map.values.map(&:labels).flatten.uniq(&:id)

        # Add labels to pull requests
        pull_requests.each do |pr|
          pr.label_ids = issues_map[pr.number].labels.map(&:id)
        end

        lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_LABELS] = labels
        lane_context[SharedValues::GENERATE_CHANGELOG_GITHUB_PULL_REQUESTS] = pull_requests

        return labels, pull_requests
      end
    end
  end
end
