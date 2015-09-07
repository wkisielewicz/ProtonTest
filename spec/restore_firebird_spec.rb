require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

describe 'Backup Firebird', :type => :feature, :js => true do

  it 'correct backup for firebird' do

    visit('http://localhost:10555/')

    page.find('button.btn-default.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
   # page.find('panel-body').text
    fill_in 'main-view-restore-wizard-data-config-tools-gbak-path',               :with => 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe'
    expect(page).to have_field('main-view-restore-wizard-data-config-tools-gbak-path', with: 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe')
    fill_in 'main-view-restore-wizard-data-config-tools-isql-path',               :with => 'C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe'
    fill_in 'main-view-restore-wizard-data-config-database-connection-string',    :with => 'C:\Program Files\Firebird\Firebird_2_5\examples\empbuild\EMPLOYEE.FDB'
    fill_in 'main-view-restore-wizard-data-config-database-login',                :with => 'SYSDBA'
    fill_in 'main-view-restore-wizard-data-config-database-password',             :with => 'masterkey'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    #expect(page).to have_content 'Success'

    fill_in 'main-view-restore-wizard-data-config-passphrase1',      :with => 'firebird'
    fill_in 'main-view-restore-wizard-data-config-passphrase2',      :with => 'firebird'
    #page.driver.render('./firebird_restore.png', :full => true)
    #page.driver.render('./firebird_restore.png', :full => true)
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    attach_file('seleniumUpload', Rails.root + './fixturies/files/plik-ratunkowy.prcv')

   #page.uploadFile('input[name=file]', 'C:\Users\kisiel\Desktop\key\plik-ratunkowy.prcv')
    #page.render('plik-ratunkowy.prcv')
    #page.find('#file').fill_in('C:\Users\kisiel\Desktop\key\plik-ratunkowy.prcv')
    #page.find('#file').click
    #fill_in :name =>'file',  :with => 'C:\Users\kisiel\Desktop\key\plik-ratunkowy.prcv'
    #page.find('#file').set('C:\Users\kisiel\Desktop\key\plik-ratunkowy.prcv')

    sleep(inspection_time=5)
    page.find('#main-view-restore-wizard-accepted').click
    sleep(inspection_time=5)

    #page.attach_file 'file', './fixturies/files/plik-ratunkowy.prcv'

   #page.find('file').click
    #page.driver.render('./firebird_restore.png', :full => true)
     #fill_in 'file',        :with => 'C:\Users\kisiel\Desktop\key\plik-ratunkowy.prcv'
    #page.attach_file 'file', 'C:\Users\kisiel\Desktop\key\plik-ratunkowy.prcv'
    #attach_file 'file',  '/fixturies/files/plik-ratunkowy.prcv'
    #attach_file('file', File.join(Rails.root, 'C:\Users\kisiel\Desktop\key\plik-ratunkowy.prcv'))

    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    #script = '$('input[type=file]').show();'
    #page.find('div.button-group > button.btn-primary.btn').click


    page.driver.render('./screenshot/firebird_restore.png', :full => true)
  end
end






