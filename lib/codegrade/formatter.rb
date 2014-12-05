module Codegrade
  class Formatter
    def initialize(offenses)
      @offenses = offenses
    end

    def print
      group_by_files
      working_directory = File.expand_path('.')

      @categories.each do |category, offenses|
        puts "#{category} (#{offenses.size}):"
        puts

        offenses.each do |offense|
          file = offense.file.gsub(working_directory, '') unless offense.file.nil?
          puts "- #{offense.line_number}:#{offense.column_number} #{offense.category}"
        end

        puts
      end
    end

    private

    def group_by_files
      @categories = Hash.new

      @offenses.each do |offense|
        @categories[offense.file] ||= []
        @categories[offense.file].push(offense)
      end
    end
  end
end