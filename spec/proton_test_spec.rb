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

describe 'Setting up Firebird Wizzard', :type => :feature, :js => true do
   #before(:each) do

     #@account=Account.new().create!

   #end

  # after(:each) do
  #
  #   @id = @account.subscription_id
  #   system("proton-provision destroy -i #{@id}")
  # end
  it 'should correct configuration firebird' do

    @account=Account.new().create!

    @key = @account.activation_key

    cb = Capybara

    cb.register_driver :my_firefox_driver do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.dir'] = "~/Downloads"
      profile['browser.download.folderList'] = 2
      profile['browser.helperApps.alwaysAsk.force'] = false
      profile['browser.download.manager.showWhenStarting'] = false
      profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream'
      profile['csvjs.disabled'] = true
      Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
    end

    cb.current_driver = :my_firefox_driver


    cb.visit('http://localhost:10555/')

    #initial proton, setup access key
    cb.page.find('div.col-sm-7 > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-user-access-token', :with =>  @key
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 8
    cb.page.find('div.button-group > button.btn-primary.btn').click
    #enter the password for the file rescue
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase1', :with => 'test'
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase2', :with => 'test'
    cb.page.find('div.button-group > button.btn-primary.btn').click
    cb.page.find('div.panel-text > button.btn-primary.btn').click
    sleep 13
    #page.driver.render('./screenshot/firebird_wizard.png', :full => true)
    cb.page.find('#initial-wizard-setup-wizard-data-config-encryption-generate-understand').click
    cb.page.find('#initial-wizard-setup-wizard-data-config-encryption-generate-accepted').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    #typing paths to the database tools firebird
    # fill_in 'config-tools-gbak-path', :with => 'C:\Program Files (x86)\Firebird\Firebird_2_5\bin\gbak.exe'
    # fill_in 'config-tools-isql-path', :with => 'C:\Program Files (x86)\Firebird\Firebird_2_5\bin\isql.exe'
    # expect(page).to have_field('config-tools-gbak-path', with: 'C:\Program Files (x86)\Firebird\Firebird_2_5\bin\gbak.exe')
    # expect(page).to have_field('config-tools-isql-path', with: 'C:\Program Files (x86)\Firebird\Firebird_2_5\bin\isql.exe')
    #cb.page.driver.render('./screenshot/firebird_wizard1.png', :full => true)
    fill_in 'initial-wizard-setup-wizard-data-config-database-connection-string', :with => 'C:\Program Files (x86)\Firebird\Firebird_2_5\examples\empbuild\EMPLOYEE.FDB'
    fill_in 'initial-wizard-setup-wizard-data-config-database-login', :with => 'SYSDBA'
    fill_in 'initial-wizard-setup-wizard-data-config-database-password', :with => 'masterkey'
    ## page.find('div.col-sm-7 > button.btn-primary.btn').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 3
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 8
    puts cb.title
    # expect(page).to have_no_content 'Error'
    #cb.page.driver.render('./screenshot/firebird_wizard.png', :full => true)
end
  ################backup###############################

    Capybara.javascript_driver = :poltergeist


    describe 'performing backup database firebird', :type => :feature, :js => true do


      it 'make a correct copy of the data for the database firebird' do
        visit('http://localhost:10555')
        page.first('button.btn-primary.btn').click
        sleep 8
        expect(page).to have_content 'wykonywanie'
        page.driver.render('./screenshot/backup_firebird.png', :full => true)
      end
    end


  #######################restore#######################

  Capybara.javascript_driver = :poltergeist

  describe 'Restoring from a backup made using proton red', :type => :feature, :js => true do

    it 'Proper restoration for a database firebird' do

      visit('http://localhost:10555/')

      page.find('button.btn-default.btn').click
      sleep 4
      page.find('div.button-group > button.btn-primary.btn').click
      sleep 10
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
   # after(:each) do
   #
   #   @id = @account.subscription_id
   #   system("proton-provision destroy -i #{@id}")
   # end
end




