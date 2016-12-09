module Fastlane
  module Helper
    class ChangelogGeneratorHelper
      def self.git_tags(limit = nil)
        tags = `git tag --sort=taggerdate`.split("\n").reverse
        tags = tags.take(limit) if limit
        tags
      end
    end
  end
end
