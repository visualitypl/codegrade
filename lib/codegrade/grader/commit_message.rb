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

        paragraph, paragraph_start, paragraph_line = [], 1, 0
        inside_punctation = false

        lines.each_with_index do |line, index|
          paragraph << line
          paragraph_line += 1

          line_number      = index + 1
          blank_line       = blank?(line)
          title_line       = line_number == 1
          end_of_paragraph = (index == lines.length - 1 ||
                             blank?(lines[index + 1])) && !title_line &&
                             paragraph.any? && !blank?(paragraph.last)

          if line.start_with?('* ')
            check_punctation_no_separating_line(inside_punctation, line_number)

            inside_punctation = true
          end

          if title_line
            check_title_leading_lowercase(line, line_number)
            check_title_too_long(line, line_number)
            check_title_trailing_dot(line, line_number)
          end

          if end_of_paragraph
            if inside_punctation
            else
              check_paragraph_leading_lowercase(paragraph, paragraph_start)
              check_paragraph_no_trailing_dot(paragraph, paragraph_start)
            end
          end

          if blank_line
            check_redundant_empty_line(paragraph, line_number)

            paragraph, paragraph_start, paragraph_line = [], line_number + 1, 0
            inside_punctation = false
          else
            check_title_multiple_lines(line_number)

            check_line_trailing_whitespace(line, line_number)
            check_line_too_long(line, line_number) unless title_line
          end

          if inside_punctation
            if paragraph_line > 1
              check_punctation_leading_whitespace(line, line_number)
            end
          else
            if ! blank_line
              check_line_leading_whitespace(line, line_number)
            end
          end
        end
      end

      def check_title_leading_lowercase(line, line_number)
        if line[0].downcase == line[0]
          add_offense(
            :category       => 'title_leading_lowercase',
            :line_number    => line_number,
            :column_number  => 1)
        end
      end

      def check_title_too_long(line, line_number)
        if line.length > 50
          add_offense(
            :category      => 'title_too_long',
            :line_number   => line_number,
            :column_number => 51)
        end
      end

      def check_title_trailing_dot(line, line_number)
        if (m = line.match(/\.\s*$/))
          add_offense(
            :category      => 'title_trailing_dot',
            :line_number   => line_number,
            :column_number => m.begin(0))
        end
      end

      def check_title_multiple_lines(line_number)
        if line_number == 2
          add_offense(
            :category    => 'title_multiple_lines',
            :line_number => line_number)
        end
      end

      def check_redundant_empty_line(paragraph, line_number)
        if paragraph.select { |line| !blank?(line) }.empty?
          add_offense(
            :category       => 'redundant_empty_line',
            :line_number    => line_number)
        end
      end

      def check_line_trailing_whitespace(line, line_number)
        if (m = line.match(/\s+$/))
          add_offense(
            :category      => 'line_trailing_whitespace',
            :line_number   => line_number,
            :column_number => m.begin(0) + 1)
        end
      end

      def check_line_leading_whitespace(line, line_number)
        if (m = line.match(/^\s+/))
          add_offense(
            :category      => 'line_leading_whitespace',
            :line_number   => line_number,
            :column_number => m.end(0))
        end
      end

      def check_line_too_long(line, line_number)
        if line.length > 70
          add_offense(
            :category      => 'line_too_long',
            :line_number   => line_number,
            :column_number => 71)
        end
      end

      def check_paragraph_leading_lowercase(paragraph, paragraph_start)
        line = strip(paragraph.first)

        if line[0].downcase == line[0] &&
            !link?(line.split[0])
          add_offense(
            :category      => 'paragraph_leading_lowercase',
            :line_number   => paragraph_start,
            :column_number => 1)
        end
      end

      def check_paragraph_no_trailing_dot(paragraph, paragraph_start)
        line = strip(paragraph.last)

        if line[-1] != '.' &&
            !link?(line.split[-1])
          add_offense(
            :category      => 'paragraph_no_trailing_dot',
            :line_number   => paragraph_start + paragraph.length - 1,
            :column_number => paragraph.last.length)
        end
      end

      def check_punctation_no_separating_line(inside_punctation, line_number)
        if inside_punctation
          add_offense(
            :category      => 'punctation_no_separating_line',
            :line_number   => line_number)
        end
      end

      def check_punctation_leading_whitespace(line, line_number)
        if (m = line.match(/^\s*/)) && m.end(0) != 2
          add_offense(
            :category      => 'punctation_leading_whitespace',
            :line_number   => line_number,
            :column_number => m.end(0))
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
