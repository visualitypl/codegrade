module Codegrade
  module Grader
    class Grader
      attr_reader :commit

      def initialize(commit)
        @commit = commit
      end

      def grade
        offenses = []

        offenses.concat(CommitMessage.new(@commit.message).grade)
        ruby_files.each do |file|
          offenses.concat(Rubocop.new(file).grade)
        end

        offenses
      end

      private

      def ruby_files
        commit.files.select { |filename| File.extname(filename) == '.rb' }
      end
    end
  end
end