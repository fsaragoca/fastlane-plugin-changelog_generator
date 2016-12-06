module Fastlane
  module Helper
    class ChangelogGeneratorRender
      attr_accessor :releases, :labels, :params

      def initialize(releases, labels, params)
        @releases = releases
        @labels = labels
        @params = params
      end

      def to_markdown
        ERB.new(params[:template], 0, '-').result(binding).strip
      end
    end
  end
end
