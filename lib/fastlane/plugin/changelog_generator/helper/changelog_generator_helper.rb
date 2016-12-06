module Fastlane
  module Helper
    class ChangelogGeneratorHelper
      # class methods that you define here become available in your action
      # as `Helper::ChangelogGeneratorHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the changelog_generator plugin helper!")
      end
    end
  end
end
