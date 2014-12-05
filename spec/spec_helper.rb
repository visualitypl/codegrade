require_relative '../lib/codegrade'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

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
