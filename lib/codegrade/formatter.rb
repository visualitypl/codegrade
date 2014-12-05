module Codegrade
  class Formatter
    def initialize(offenses)
      @offenses = offenses
    end

    def print
      group_by_categories

      @categories.each do |category, offenses|
        puts "#{category} (#{offenses.size}):"
        puts

        offenses.each do |offense|
          puts "- #{offense.line_number}:#{offense.column_number} #{offense.category}"
        end

        puts
      end
    end

    private

    def group_by_categories
      @categories = Hash.new

      @offenses.each do |offense|
        @categories[offense.category] ||= []
        @categories[offense.category].push(offense)
      end
    end
  end
end