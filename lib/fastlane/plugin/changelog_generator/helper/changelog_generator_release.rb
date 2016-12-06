module Fastlane
  module Helper
    class ChangelogGeneratorRelease
      attr_accessor :data, :from_tag, :to_tag, :date

      def initialize(labels, pull_requests, from_tag, to_tag)
        from_date = date_for_commit_with_tag(from_tag)
        to_date = date_for_commit_with_tag(to_tag)

        # Ensure dates & tags are ascending
        if from_date && to_date && from_date > to_date
          tag = from_tag
          from_tag = to_tag
          to_tag = tag

          date = from_date
          from_date = to_date
          to_date = date
        end

        @from_tag = from_tag
        @to_tag = to_tag
        @date = to_date
        @data = {}

        labels.each do |label|
          filtered_pull_requests = pull_requests.select do |pr|
            includes_label = pr.label_ids.include?(label.id)
            in_date_range = pr.merged_at && (!from_date || pr.merged_at > from_date) && (!to_date || pr.merged_at < to_date)
            includes_label && in_date_range
          end
          @data[label] = filtered_pull_requests if filtered_pull_requests.count > 0
        end
      end

      def display_title
        if to_tag
          "[#{to_tag}] - #{date.strftime('%Y-%m-%d')}"
        else
          "[Unreleased]"
        end
      end

      private

      def date_for_commit_with_tag(tag)
        Time.parse(`git show -s --format=%ci $(git rev-list -n 1 #{tag})`.strip) if tag
      end
    end
  end
end
