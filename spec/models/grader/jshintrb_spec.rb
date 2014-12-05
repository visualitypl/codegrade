require 'spec_helper'

describe Codegrade::Grader::Jshintrb do
  context 'unnamed function' do
    let(:content) do
      "\n\nfunction () { }"
    end

    it 'returns relevant error' do
      grader = Codegrade::Grader::Jshintrb.new(content)
      grader.grade

      expect(find_offense(grader,
        :category => 'missing_name_in_function_declaration',
        :line_number => 3)).not_to be_nil
    end
  end

  context 'missing semicolon' do
    let(:content) do
      "function f1 () {\n x = 1;\n y = 2 \n}"
    end

    it 'returns relevant error' do
      grader = Codegrade::Grader::Jshintrb.new(content)
      grader.grade

      expect(find_offense(grader,
        :category => 'missing_semicolon',
        :line_number => 3)).not_to be_nil
    end
  end
end
