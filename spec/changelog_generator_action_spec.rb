describe Fastlane::Actions::ChangelogGeneratorAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The changelog_generator plugin is working!")

      Fastlane::Actions::ChangelogGeneratorAction.run(nil)
    end
  end
end
