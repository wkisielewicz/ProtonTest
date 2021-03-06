require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'protontest'

Capybara.javascript_driver = :poltergeist

describe 'restore data using key from 0.8.6 version', :type => :feature, :js => true do

  let(:fb) {Firebird_Variables.new(:gbak_path,:isql_path,:full_path,:login,:password_firebird_database,:wrong_password,:security_password)}

  it 'should correct restore data using key from 0.8.6 versions' do

    visit('http://localhost:10555/')

    page.find('button.btn-default.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    fill_in 'main-view-restore-wizard-data-config-database-connection-string', with: fb.full_path
    fill_in 'main-view-restore-wizard-data-config-database-login', with: fb.login
    fill_in 'main-view-restore-wizard-data-config-database-password', with: fb.password_firebird_database
    page.find('div.col-sm-7 > button.btn-primary.btn').click

    fill_in 'main-view-restore-wizard-data-config-passphrase1', with: fb.security_password
    fill_in 'main-view-restore-wizard-data-config-passphrase2', with: fb.security_password
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    page.driver.render('./screenshot/firebird_restore.png', :full => true)
    attach_file('file', 'spec/rescue_file/plik-ratunkowy0.8.6.prcv')
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('#main-view-restore-wizard-safety-copy').click
    page.find('label > span').click
    page.find('div.button-group > button.btn-primary.btn').click
    find(:xpath, "//input[@id='main-view-restore-wizard-accepted']").click
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.driver.render('./screenshot/firebird_restore.png', :full => true)
  end
end






