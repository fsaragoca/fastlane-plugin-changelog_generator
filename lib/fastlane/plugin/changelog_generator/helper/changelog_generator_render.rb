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
        template = params[:template] || File.read(params[:template_path])
        markdown = ERB.new(template, 0, '-').result(binding).strip.concat("\n")
        File.write(params[:output_path], markdown) if params[:output_path]
        markdown
      end
    end
  end
end
