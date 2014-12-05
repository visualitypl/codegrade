require 'rubocop'

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
          Offense.new(rubocop_offense)
        end
      end

      private

      def classes
        RuboCop::Cop::Cop.all.reject do |cop|
          cop.rails?
        end
      end
    end
  end
end