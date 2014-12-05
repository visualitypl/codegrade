module Codegrade
  module Grader
    class CommitMessage
      attr_reader :offenses

      def initialize(message)
        @message = message
      end

      def grade
        clear_offenses
        parse_commit_message
      end

      private

      def clear_offenses
        @offenses = []
      end

      def parse_commit_message
        lines = @message.split("\n")
        state = {
          :paragraph         => [],
          :paragraph_start   => 1,
          :inside_punctation => false }

        lines.each_with_index do |line, index|
          state[:paragraph] << line

          state.merge!(
            :line                => line,
            :index               => index,
            :line_number         => index + 1,
            :blank_line          => blank?(line),
            :title_line          => index == 0,
            :start_of_punctation => line.start_with?('* '),
            :was_in_punctation   => state[:inside_punctation])

          state[:end_of_paragraph] = !state[:title_line] &&
            state[:paragraph].any? &&
            (index == lines.length - 1 || blank?(lines[index + 1])) &&
            !blank?(state[:paragraph].last)

          state[:inside_punctation] = state[:inside_punctation] ||
            state[:start_of_punctation]

          check_title_leading_lowercase(state)
          check_title_too_long(state)
          check_title_trailing_dot(state)
          check_title_multiple_lines(state)

          check_line_trailing_whitespace(state)
          check_line_too_long(state)
          check_line_leading_whitespace(state)
          check_redundant_empty_line(state)

          check_punctation_leading_whitespace(state)
          check_punctation_leading_lowercase(state)
          check_punctation_trailing_dot(state)
          check_punctation_no_separating_line(state)

          check_paragraph_leading_lowercase(state)
          check_paragraph_no_trailing_dot(state)

          if state[:blank_line]
            state.merge!(
              :paragraph         => [],
              :paragraph_start   => state[:line_number] + 1,
              :inside_punctation => false)
          end
        end
      end

      def check_title_leading_lowercase(state)
        if state[:title_line] && state[:line][0].downcase == state[:line][0]
          add_offense(
            :category       => 'title_leading_lowercase',
            :line_number    => state[:line_number],
            :column_number  => 1)
        end
      end

      def check_title_too_long(state)
        if state[:title_line] && state[:line].length > 50
          add_offense(
            :category      => 'title_too_long',
            :line_number   => state[:line_number],
            :column_number => 51)
        end
      end

      def check_title_trailing_dot(state)
        if state[:title_line] && (m = state[:line].match(/\.\s*$/))
          add_offense(
            :category      => 'title_trailing_dot',
            :line_number   => state[:line_number],
            :column_number => m.begin(0))
        end
      end

      def check_title_multiple_lines(state)
        return if state[:blank_line]

        if state[:line_number] == 2
          add_offense(
            :category    => 'title_multiple_lines',
            :line_number => state[:line_number])
        end
      end

      def check_redundant_empty_line(state)
        return unless state[:blank_line]

        if state[:paragraph].select { |line| !blank?(line) }.empty?
          add_offense(
            :category       => 'redundant_empty_line',
            :line_number    => state[:line_number])
        end
      end

      def check_line_trailing_whitespace(state)
        return if state[:blank_line]

        if (m = state[:line].match(/\s+$/))
          add_offense(
            :category      => 'line_trailing_whitespace',
            :line_number   => state[:line_number],
            :column_number => m.begin(0) + 1)
        end
      end

      def check_line_leading_whitespace(state)
        if !state[:inside_punctation] &&
            !state[:blank_line] &&
            (m = state[:line].match(/^\s+/))
          add_offense(
            :category      => 'line_leading_whitespace',
            :line_number   => state[:line_number],
            :column_number => m.end(0))
        end
      end

      def check_line_too_long(state)
        return if state[:blank_line] || state[:title_line]

        if state[:line].length > 70
          add_offense(
            :category      => 'line_too_long',
            :line_number   => state[:line_number],
            :column_number => 71)
        end
      end

      def check_paragraph_leading_lowercase(state)
        return unless state[:end_of_paragraph] && !state[:inside_punctation]

        line = strip(state[:paragraph].first)

        if line[0].downcase == line[0] &&
            !link?(line.split[0])
          add_offense(
            :category      => 'paragraph_leading_lowercase',
            :line_number   => state[:paragraph_start],
            :column_number => 1)
        end
      end

      def check_paragraph_no_trailing_dot(state)
        return unless state[:end_of_paragraph] && !state[:inside_punctation]

        line = strip(state[:paragraph].last)

        if line[-1] != '.' &&
            !link?(line.split[-1])
          add_offense(
            :category      => 'paragraph_no_trailing_dot',
            :line_number   => state[:paragraph_start] +
                              state[:paragraph].length - 1,
            :column_number => state[:paragraph].last.length)
        end
      end

      def check_punctation_no_separating_line(state)
        if state[:start_of_punctation] && state[:was_in_punctation]
          add_offense(
            :category      => 'punctation_no_separating_line',
            :line_number   => state[:line_number])
        end
      end

      def check_punctation_leading_whitespace(state)
        if state[:inside_punctation] &&
            !state[:blank_line] &&
            state[:paragraph].length > 1 &&
            (m = state[:line].match(/^\s*/)) && m.end(0) != 2
          add_offense(
            :category      => 'punctation_leading_whitespace',
            :line_number   => state[:line_number],
            :column_number => m.end(0))
        end
      end

      def check_punctation_leading_lowercase(state)
        return unless state[:end_of_paragraph] && state[:inside_punctation]

        line = strip(state[:paragraph].first)

        if line[2].downcase == line[2] &&
            !link?(line.split[0])
          add_offense(
            :category      => 'punctation_leading_lowercase',
            :line_number   => state[:paragraph_start],
            :column_number => 3)
        end
      end

      def check_punctation_trailing_dot(state)
        return unless state[:end_of_paragraph] && state[:inside_punctation]

        line = strip(state[:paragraph].last)

        if line[-1] == '.' &&
            !link?(line.split[-1])
          add_offense(
            :category      => 'punctation_trailing_dot',
            :line_number   => state[:paragraph_start] +
                              state[:paragraph].length - 1,
            :column_number => state[:paragraph].last.length)
        end
      end

      def add_offense(params)
        @offenses << Codegrade::Offense.new(params)
      end

      def strip(text)
        text.match(/(\S.*\S)/).to_s
      end

      def blank?(text)
        text.match(/^\s*$/)
      end

      def link?(text)
        text.include?('://') || text.start_with?('www.')
      end
    end
  end
end
