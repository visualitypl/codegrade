module Codegrade
  module Grader
    class CommitMessage
      attr_reader :errors

      def initialize(message)
        @message = message
      end

      def execute
        @errors = []

        parse_commit_message
      end

      private

      def parse_commit_message
        lines = @message.split("\n")

        paragraph, paragraph_start, paragraph_line = [], 1, 0

        lines.each_with_index do |line, index|
          line_number = index + 1
          paragraph << line
          paragraph_line += 1

          if line_number == 1
            check_title_leading_lowercase(line, line_number)
          end

          if blank?(line)
            check_redundant_empty_line(paragraph, line_number)

            paragraph, paragraph_start, paragraph_line = [], line_number, 0
          else
            check_line_trailing_whitespace(line, line_number)
          end
        end
      end

      def check_title_leading_lowercase(line, line_number)
        if line[0].downcase == line[0]
          @errors << {
            :category       => 'title_leading_lowercase',
            :line_number    => line_number,
            :column_number  => 1
          }
        end
      end

      def check_redundant_empty_line(paragraph, line_number)
        if paragraph.select { |line| !blank?(line) }.empty?
          @errors << {
            :category       => 'redundant_empty_line',
            :line_number    => line_number,
            :column_number  => nil
          }
        end
      end

      def check_line_trailing_whitespace(line, line_number)
        if (m = line.match(/\s+$/))
          @errors << {
            :category      => 'line_trailing_whitespace',
            :line_number   => line_number,
            :column_number => m.begin(0) + 1
          }
        end
      end

      def blank?(text)
        text.match(/^\s*$/)
      end
    end
  end
end
