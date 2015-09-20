require 'rspec'
require 'provision'
require 'capybara/poltergeist'


Capybara.javascript_driver = :poltergeist

#include ActionDispatch::TestProcess


RSpec.configure do |config|

  config.expect_with :rspec do |expectations|

    expectations.include_chain_clauses_in_custom_matcher_descriptions = true

    config.include Capybara::DSL
  end


  config.mock_with :rspec do |mocks|

    mocks.verify_partial_doubles = true
  end




 end
