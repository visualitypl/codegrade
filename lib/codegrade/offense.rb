module Codegrade
  class Offense < OpenStruct
    def initialize(params)
      params = OpenStruct.new(params)

      super(
        :category       => params[:category],
        :line_number    => params[:line_number],
        :column_number  => params[:column_number],
        :file           => params[:file],
        :source         => params[:source]
      )
    end

    def message
      m = category.split('_').join(' ')
      m = m[0].upcase + m[1..-1]

      m
    end
  end
end
