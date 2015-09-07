require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

describe 'change harmonogram', :type => :feature, :js => true do

  it 'change harmonogram' do
    visit('http://localhost:10555')
      page.find('#config-schedule-monday').click
      page.find('#config-schedule-tuesday').click
      fill_in 'config-schedule-start-at',   :with => '15:00'
      page.find('div.col-sm-7 > button.btn-primary.btn').click
    page.driver.render('./screenshot/harmonogram.png', :full => true)
    end
  end

