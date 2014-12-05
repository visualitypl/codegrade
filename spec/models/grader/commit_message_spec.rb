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

      expect(grader.errors).to be_empty
    end
  end

  context 'title starting with small letter' do
    let(:message) { "wrong commit" }

    it 'returns relevant error' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(find_error(grader,
        :category    => 'title_leading_lowercase',
        :line_number => 1)).not_to be_nil
    end
  end

  context 'redundant empty lines' do
    let(:message) do
      "Commit


One redundant empty line above.\n  \n
One more redundant blank line above.



Two here."
    end

    it 'returns relevant errors' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(grader.errors.count).to eq 4
      expect(find_error(grader,
        :category    => 'redundant_empty_line',
        :line_number => 3)).not_to be_nil
      expect(find_error(grader,
        :category    => 'redundant_empty_line',
        :line_number => 6)).not_to be_nil
      expect(find_error(grader,
        :category    => 'redundant_empty_line',
        :line_number => 9)).not_to be_nil
      expect(find_error(grader,
        :category    => 'redundant_empty_line',
        :line_number => 10)).not_to be_nil
    end
  end

  context 'line with trailing whitespace' do
    let(:message) do
      "Commit  \n
Another line. \nLast line."
    end

    it 'returns relevant errors' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(grader.errors.count).to eq 2
      expect(find_error(grader,
        :category      => 'line_trailing_whitespace',
        :line_number   => 1,
        :column_number => 7)).not_to be_nil
      expect(find_error(grader,
        :category      => 'line_trailing_whitespace',
        :line_number   => 3,
        :column_number => 14)).not_to be_nil
    end
  end

  context 'line outside punctation with leading whitespace' do
    let(:message) do
      "Commit

  Wrong indent.

 Another
      and one more."
    end

    it 'returns relevant errors' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(grader.errors.count).to eq 3
      expect(find_error(grader,
        :category      => 'line_leading_whitespace',
        :line_number   => 3,
        :column_number => 2)).not_to be_nil
      expect(find_error(grader,
        :category      => 'line_leading_whitespace',
        :line_number   => 5,
        :column_number => 1)).not_to be_nil
      expect(find_error(grader,
        :category      => 'line_leading_whitespace',
        :line_number   => 6,
        :column_number => 6)).not_to be_nil
    end
  end

  context 'too long line outside of title' do
    let(:message) do
      "Commit

Another line that is longer than 70 characters and violates our sacred rules."
    end

    it 'returns relevant error' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(find_error(grader,
        :category      => 'line_too_long',
        :line_number   => 3,
        :column_number => 71)).not_to be_nil
    end
  end
end
