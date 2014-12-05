require 'spec_helper'

describe Codegrade::Grader::CommitMessage do
  def find_error(grader, conditions = {})
    grader.errors.find do |error|
      all_met = true

      conditions.each do |key, value|
        if error[key] != value
          all_met = false
          break
        end
      end

      all_met
    end
  end

  context 'proper reference commit' do
    let(:message) do
      "Implement perfect commit

      This is some text. It can have sentences as it's a
      regular paragraph. It's close to unlimited.

      http://www.google.pl/

      * This is a first punctor with multiple lines
        and an useful content

      * This is a second, with just one line

      Ending comment here."
    end

    it 'returns no errors' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      error_categories = grader.errors.map { |e| e[:category] }

      expect(grader.errors).to be_empty
    end
  end

  context 'title starting with small letter' do
    let(:message) { "wrong commit" }

    it 'returns relevant error' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      error_categories = grader.errors.map { |e| e[:category] }

      expect(find_error(grader,
        :category    => 'title_leading_lowercase',
        :line_number => 1)).not_to be_nil
    end
  end
end
