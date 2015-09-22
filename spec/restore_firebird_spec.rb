require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

describe 'Restoring from a backup made using proton red', :type => :feature, :js => true do

  it 'Proper restoration for a database firebird' do

    visit('http://localhost:10555/')

    page.find('button.btn-default.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    # page.find('panel-body').text
    #  fill_in 'main-view-restore-wizard-data-config-tools-gbak-path',               :with => 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe'
    #  expect(page).to have_field('main-view-restore-wizard-data-config-tools-gbak-path', with: 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe')
    #  fill_in 'main-view-restore-wizard-data-config-tools-isql-path',               :with => 'C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe'
    fill_in 'main-view-restore-wizard-data-config-database-connection-string', :with => 'C:\Program Files (x86)\Firebird\Firebird_2_5\examples\empbuild\EMPLOYEE.FDB'
    fill_in 'main-view-restore-wizard-data-config-database-login', :with => 'SYSDBA'
    fill_in 'main-view-restore-wizard-data-config-database-password', :with => 'masterkey'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    #
    fill_in 'main-view-restore-wizard-data-config-passphrase1', :with => 'test'
    fill_in 'main-view-restore-wizard-data-config-passphrase2', :with => 'test'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    page.find('#main-view-restore-wizard-accepted').click
    page.find('label > span').click
    attach_file('file', 'C:\\Users\\kisiel\\Downloads\\plik-ratunkowy.prcv')

    sleep(inspection_time=8)
    page.find('#main-view-restore-wizard-accepted').click
    sleep(inspection_time=5)

    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.driver.render('./screenshot/firebird_restore.png', :full => true)
  end
end






