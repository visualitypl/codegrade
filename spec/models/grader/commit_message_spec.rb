require 'spec_helper'

describe Codegrade::Grader::CommitMessage do
  def find_offense(grader, conditions = {})
    grader.offenses.find do |error|
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

      expect(grader.offenses).to be_empty
    end
  end

  context 'title starting with small letter' do
    let(:message) { "wrong commit" }

    it 'returns relevant error' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(find_offense(grader,
        :category    => 'title_leading_lowercase',
        :line_number => 1)).not_to be_nil
    end
  end

  context 'title too long' do
    let(:message) { "Wrong commit with more that 50 chars that is just wrong" }

    it 'returns relevant error' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(grader.offenses.count).to eq 1
      expect(find_offense(grader,
        :category    => 'title_too_long',
        :line_number => 1)).not_to be_nil
    end
  end

  context 'title ending with a dot' do
    let(:message) { "Wrong commit with dot." }

    it 'returns relevant error' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(grader.offenses.count).to eq 1
      expect(find_offense(grader,
        :category      => 'title_trailing_dot',
        :line_number   => 1,
        :column_number => 21)).not_to be_nil
    end
  end

  context 'title with multiple lines' do
    let(:message) { "Wrong commit with\ntitle in multiple lines." }

    it 'returns relevant error' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(grader.offenses.count).to eq 1
      expect(find_offense(grader,
        :category      => 'title_multiple_lines',
        :line_number   => 2)).not_to be_nil
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

      expect(grader.offenses.count).to eq 4
      expect(find_offense(grader,
        :category    => 'redundant_empty_line',
        :line_number => 3)).not_to be_nil
      expect(find_offense(grader,
        :category    => 'redundant_empty_line',
        :line_number => 6)).not_to be_nil
      expect(find_offense(grader,
        :category    => 'redundant_empty_line',
        :line_number => 9)).not_to be_nil
      expect(find_offense(grader,
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

      expect(grader.offenses.count).to eq 2
      expect(find_offense(grader,
        :category      => 'line_trailing_whitespace',
        :line_number   => 1,
        :column_number => 7)).not_to be_nil
      expect(find_offense(grader,
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
      and one more.

* Punctation
  OK"
    end

    it 'returns relevant errors' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(grader.offenses.count).to eq 3
      expect(find_offense(grader,
        :category      => 'line_leading_whitespace',
        :line_number   => 3,
        :column_number => 2)).not_to be_nil
      expect(find_offense(grader,
        :category      => 'line_leading_whitespace',
        :line_number   => 5,
        :column_number => 1)).not_to be_nil
      expect(find_offense(grader,
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

      expect(find_offense(grader,
        :category      => 'line_too_long',
        :line_number   => 3,
        :column_number => 71)).not_to be_nil
    end
  end

  context 'punctation with no separating line' do
    let(:message) do
      "Commit

* Punctation
  OK

* Punctation
  close 1
* Punctation
  close 2"
    end

    it 'returns relevant errors' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(find_offense(grader,
        :category      => 'punctation_no_separating_line',
        :line_number   => 8)).not_to be_nil
    end
  end

  context 'punctation with wrong leading whitespace' do
    let(:message) do
      "Commit

* Punctation
small

* Punctation
  OK

* Punctation
   big"
    end

    it 'returns relevant errors' do
      grader = Codegrade::Grader::CommitMessage.new(message)
      grader.execute

      expect(find_offense(grader,
        :category      => 'punctation_leading_whitespace',
        :line_number   => 4,
        :column_number => 0)).not_to be_nil
      expect(find_offense(grader,
        :category      => 'punctation_leading_whitespace',
        :line_number   => 10,
        :column_number => 3)).not_to be_nil
    end
  end
end
