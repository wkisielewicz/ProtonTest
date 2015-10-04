require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'protontest'

Capybara.javascript_driver = :poltergeist

describe 'Restoring from a backup made using proton red', :type => :feature, :js => true do

  let(:fb) {Firebird_Variables.new(:gbak_path,:isql_path,:full_path,:login,:password,:wrong_password,:security_password)}

  it 'Proper restoration for a database firebird' do

    visit('http://localhost:10555/')

    page.find('button.btn-default.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    # page.find('panel-body').text
    #  fill_in 'main-view-restore-wizard-data-config-tools-gbak-path',               :with => 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe'
    #  expect(page).to have_field('main-view-restore-wizard-data-config-tools-gbak-path', with: 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe')
    #  fill_in 'main-view-restore-wizard-data-config-tools-isql-path',               :with => 'C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe'
    fill_in 'main-view-restore-wizard-data-config-database-connection-string', with: fb.full_path
    fill_in 'main-view-restore-wizard-data-config-database-login', with: fb.login
    fill_in 'main-view-restore-wizard-data-config-database-password', with: fb.password
    page.find('div.col-sm-7 > button.btn-primary.btn').click

    #
    fill_in 'main-view-restore-wizard-data-config-passphrase1', with: fb.security_password
    fill_in 'main-view-restore-wizard-data-config-passphrase2', with: fb.security_password
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    page.driver.render('./screenshot/firebird_restore.png', :full => true)
    attach_file('file', 'C:\\Users\\kisiel\\Downloads\\plik-ratunkowy.prcv')
    page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    page.find('div.button-group > button.btn-primary.btn').click

    sleep 5
    page.find('#main-view-restore-wizard-safety-copy').click
    sleep 5
    page.find('label > span').click

    page.find('div.button-group > button.btn-primary.btn').click
    sleep 4
    #page.find('#main-view-restore-wizard-accepted').click
    find(:xpath, "//input[@id='main-view-restore-wizard-accepted']").click
    sleep 5
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    sleep 3
    page.driver.render('./screenshot/firebird_restore.png', :full => true)
  end
end






