require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

describe 'change the schedule for automatic backup proton red', :type => :feature, :js => true do

  before(:each) do

    visit('http://localhost:10555')

  end

  it 'enter the correct value for the schedule' do
    page.find('#config-schedule-monday').click
    page.find('#config-schedule-tuesday').click
    fill_in 'config-schedule-start-at', :with => '15:00'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    page.driver.render('./screenshot/harmonogram.png', :full => true)
  end
  it 'enter the incorrect value for the schedule' do
    page.find('#config-schedule-monday').click
    page.find('#config-schedule-tuesday').click
    fill_in 'config-schedule-start-at', :with => '15;00'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    expect(page).to have_content 'format czasu'
    page.driver.render('./screenshot/harmonogram1.png', :full => true)
  end
end

