require 'openssl'
require 'rspec'
require 'provision'
require_relative 'spec_helper'
require_relative 'protontest'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require 'capybara/dsl'

describe 'Setting up Firebird Wizzard', :type => :feature, :js => true do

  let(:fb) {Firebird_Variables.new(:gbak_path,:isql_path,:full_path,:login,:password,:wrong_password,:security_password)}
  before(:each) do

    @account=Account.new().create!

  end

  # after(:each) do
  #
  #   @id = @account.subscription_id
  #   system("proton-provision destroy -i #{@id}")
  # end
  it 'should correct configuration firebird' do

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

    #initial proton, setup acces key
    cb.page.find('div.col-sm-7 > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-user-access-token', :with => @key
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    cb.page.find('div.button-group > button.btn-primary.btn').click
    #enter the password for the file rescue
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase1', with: fb.security_password
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase2', with: fb.security_password
    cb.page.find('div.button-group > button.btn-primary.btn').click
    cb.page.find('div.panel-text > button.btn-primary.btn').click
    sleep 13
    #page.driver.render('./screenshot/firebird_wizard.png', :full => true)
    cb.page.find('#initial-wizard-setup-wizard-data-config-encryption-generate-understand').click
    cb.page.find('#initial-wizard-setup-wizard-data-config-encryption-generate-accepted').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    #typing paths to the database tools firebird
    # fill_in 'config-tools-gbak-path', with: 'fb.gbak_path
    # fill_in 'config-tools-isql-path', with: fb.isql_path
    # expect(page).to have_field('config-tools-gbak-path', with: fb.gbak_path
    # expect(page).to have_field('config-tools-isql-path', with: fb.isql_path
    #cb.page.driver.render('./screenshot/firebird_wizard1.png', :full => true)
    fill_in 'initial-wizard-setup-wizard-data-config-database-connection-string', with: fb.full_path
    fill_in 'initial-wizard-setup-wizard-data-config-database-login', with: fb.login
    fill_in 'initial-wizard-setup-wizard-data-config-database-password', with: fb.password
    ## page.find('div.col-sm-7 > button.btn-primary.btn').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep(inspection_time=5)
    # expect(page).to have_no_content 'Error'
    #cb.page.driver.render('./screenshot/firebird_wizard.png', :full => true)

  end
end




