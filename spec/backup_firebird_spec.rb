require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist


describe 'performing backup database firebird', :type => :feature, :js => true do

  before(:each) do

    visit('http://localhost:10555')

  end

  it 'make a correct copy of the data for the database firebird' do
    page.find('button.btn-primary.btn').click
    sleep 6
    expect(page).to have_content 'wykonywanie'
    page.driver.render('./screenshot/backup_firebird.png', :full => true)
  end
end








