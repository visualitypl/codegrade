require 'spec_helper'

describe Codegrade::Grader::Grader do
  it 'combines all grades in one array' do
    allow_any_instance_of(Codegrade::Grader::CommitMessage).to receive(:grade)
    allow_any_instance_of(Codegrade::Grader::CommitMessage).to receive(:offenses).and_return([Codegrade::Offense.new(category: 'Commit message error')])
    allow_any_instance_of(Codegrade::Grader::Rubocop).to receive(:grade).and_return([Codegrade::Offense.new(category: 'Ruby syntax error')])
    commit = Codegrade::Commit.new
    allow(commit).to receive(:message).and_return('Some commit message')
    allow(commit).to receive(:files).and_return(['file.rb'])

    offenses = Codegrade::Grader::Grader.new(commit).grade

    expect(offenses.map(&:category)).to include('Commit message error')
    expect(offenses.map(&:category)).to include('Ruby syntax error')
  end
end