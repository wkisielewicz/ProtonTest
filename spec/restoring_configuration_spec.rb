require 'openssl'
require 'rspec'
require 'provision'
require_relative 'spec_helper'
require_relative 'protontest'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require 'capybara/dsl'


Capybara.javascript_driver = :poltergeist

describe 'Restoring configuration ',  :type => :feature, :js => true do

  it 'restoring configuration using rescue file' do
    visit('http://localhost:10555')
    find(:xpath, "(//input[@id='initial-wizard-wizard-mode'])[2]").click
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-config-passphrase1', :with => 'test'
    fill_in 'initial-wizard-setup-wizard-data-config-passphrase2', :with => 'test'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    attach_file('file', 'C:\\plik-ratunkowy.prcv')
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.driver.render('./screenshot/restoring_configuration_rescue_file.png', :full => true)
  end
end
