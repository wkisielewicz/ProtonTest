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

  $account=Account.new().create!

  #end

  it 'should correct configuration firebird and create rescue file with config' do

    @key = $account.activation_key

    cb = Capybara

    cb.register_driver :my_firefox_driver do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.dir'] = "~/Downloads"
      profile['browser.download.folderList'] = 2  #2-the last folder specified for a download
      profile['browser.helperApps.alwaysAsk.force'] = false
      profile['browser.download.manager.showWhenStarting'] = false
      profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream'
      profile['csvjs.disabled'] = true
      Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
    end

    cb.current_driver = :my_firefox_driver


    cb.visit('http://localhost:10555/')

    cb.page.find('div.col-sm-7 > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-user-access-token', :with =>  @key
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 6
    cb.page.find('div.button-group > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-config-database-connection-string', :with => 'C:\Program Files (x86)\Firebird\Firebird_2_5\examples\empbuild\EMPLOYEE.FDB'
    fill_in 'initial-wizard-setup-wizard-data-config-database-login', :with => 'SYSDBA'
    fill_in 'initial-wizard-setup-wizard-data-config-database-password', :with => 'masterkey'
    sleep 5
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 3
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase1', :with => 'test'
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase2', :with => 'test'
    cb.page.find('div.button-group > button.btn-primary.btn').click
    cb.page.find('div.panel-text > button.btn-primary.btn').click
    sleep 13
    cb.page.find('#initial-wizard-setup-wizard-data-config-encryption-generate-understand').click
    cb.page.find('#initial-wizard-setup-wizard-data-config-encryption-generate-accepted').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    cb.page.find('div.button-group > button.btn-primary.btn').click

  end

  Capybara.javascript_driver = :poltergeist


  describe 'performing backup database firebird', :type => :feature, :js => true do


    it 'restoring configuration using rescue file' do

        visit('http://localhost:10555')
        find(:xpath, "(//input[@id='initial-wizard-wizard-mode'])[2]").click
        page.find('div.col-sm-7 > button.btn-primary.btn').click
        sleep 5
        fill_in 'initial-wizard-setup-wizard-data-config-passphrase1', :with => 'test'
        fill_in 'initial-wizard-setup-wizard-data-config-passphrase2', :with => 'test'
        page.find('div.col-sm-7 > button.btn-primary.btn').click
        sleep 4
        attach_file('file', 'C:\\Users\\kisiel\\Downloads\\plik-ratunkowy.prcv')
        sleep 4
        page.find('div.button-group > button.btn-primary.btn').click
        page.find('div.button-group > button.btn-primary.btn').click
        sleep 5
        page.driver.render('./screenshot/restoring_configuration_rescue_file.png', :full => true)

      end
    end
  end


