module Codegrade
  class Formatter
    def initialize(offenses)
      @offenses = offenses
    end

    def print
      group_by_categories
      working_directory = File.expand_path('.')

      @categories.each do |category, offenses|
        puts "#{category} (#{offenses.size}):"
        puts

        offenses.each do |offense|
          file = offense.file.gsub(working_directory, '')[1..-1]
          puts "- #{file}:#{offense.line_number}:#{offense.column_number}"
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