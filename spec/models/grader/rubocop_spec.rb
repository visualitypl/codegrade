require 'spec_helper'
require 'tempfile'

describe Codegrade::Grader::Rubocop do
  def make_tempfile(content)
    file = Tempfile.new('file.rb')
    file.write(content)
    file.rewind

    file
  end

  def close_tempfile(file)
    file.close
    file.unlink
  end

  it 'detects errors in ruby code' do
    file = make_tempfile(<<-EOD)
      class Test
        puts 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s.'
      end
    EOD

    offenses = Codegrade::Grader::Rubocop.new(file).grade
    offense = offenses.detect { |o| o.category =~ /Line is too long/ }
    
    expect(offense.category).to eq('Line is too long. [165/80]')
    expect(offense.line_number).to eq(2)

    close_tempfile(file)
  end
end