#require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist


describe 'copy firebird', :type => :feature, :js => true do

  it 'correct copy firebird' do
    visit('http://localhost:10555/')
    #find('btn-primary').click
    page.find('button.btn-primary.btn').click
    expect(page).to have_content 'wykonywanie'
    page.driver.render('./screenshot/backup_firebird.png', :full => true)
    end
  end








