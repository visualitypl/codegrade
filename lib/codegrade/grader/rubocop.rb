module Codegrade
  module Grader
    class Rubocop
      attr_reader :config_store, :file

      def initialize(file)
        @config_store = RuboCop::ConfigStore.new
        @file = file
      end

      def grade
        processed_file = RuboCop::ProcessedSource.from_file(file)
        config = config_store.for(processed_file.path)
        team = RuboCop::Cop::Team.new(classes, config, {})

        team.inspect_file(processed_file).map do |rubocop_offense|
          Offense.new(category: rubocop_offense.message,
            line_number: rubocop_offense.line,
            column_number: rubocop_offense.real_column,
            file: file,
            source: rubocop_offense.location.source)
        end
      end

      private

      def classes
        skipped_cops = ['Style/AlignParameters']

        RuboCop::Cop::Cop.all.reject do |cop|
          cop.rails? || skipped_cops.include?(cop.cop_name)
        end
      end
    end
  end
end