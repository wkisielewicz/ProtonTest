#require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist



describe 'some stuff which requires js', :type => :feature, :js => true do
  #include Capybara::DSL
  it 'will take a screenshot' do
    visit('http://google.com')
    page.driver.render('./screenshot/example.png', :full => true)
  end
end