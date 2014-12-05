module Codegrade
  module Grader
    class Jshintrb
      attr_reader :offenses

      def initialize(content)
        @content = content
      end

      def grade
        @offenses = ::Jshintrb.lint(@content).collect do |data|
          category = data['raw'].downcase.gsub(
            /\W/, '_').gsub(/_+/, '_').gsub(/_$/, '')

          Codegrade::Offense.new(
            :category       => category,
            :line_number    => data['line'],
            :column_number  => data['character'])
        end
      end
    end
  end
end
