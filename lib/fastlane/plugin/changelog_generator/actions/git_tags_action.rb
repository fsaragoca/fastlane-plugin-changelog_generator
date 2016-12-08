module Fastlane
  module Actions
    class GitTagsAction < Action
      def self.run(params)
        tags = `git tag --sort=taggerdate`.split("\n").reverse
        tags = tags.take(params[:limit]) if params[:limit]
        tags
      end

      def self.description
        "Git tags sorted by taggerdate"
      end

      def self.authors
        ["Fernando Saragoca"]
      end

      def self.return_value
        "Array of git tags sorted by taggerdate"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :limit,
                                       env_name: 'GIT_TAGS_LIMIT',
                                       description: 'Limit number of tags to return',
                                       is_string: false,
                                       optional: true)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
