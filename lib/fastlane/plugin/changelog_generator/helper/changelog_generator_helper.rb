module Fastlane
  module Helper
    class ChangelogGeneratorHelper
      def self.git_tags(limit = nil)
        tags = `git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}'`.split("\n").reverse
        tags = tags.take(limit) if limit
        tags
      end
    end
  end
end
