require 'octokit'

module Fastlane
  module Helper
    class ChangelogGeneratorFetcher
      def self.fetch_labels(project, base_branch, access_token)
        Octokit.auto_paginate = true

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
        pull_requests.sort_by! do |pr|
          pr.merged_at
        end

        # Uniq labels
        labels = issues_map.values.map(&:labels).flatten.uniq do |label|
          label.id
        end

        # Add labels to pull requests
        pull_requests.each do |pr|
          pr.label_ids = issues_map[pr.number].labels.map(&:id)
        end

        return labels, pull_requests
      end
    end
  end
end
