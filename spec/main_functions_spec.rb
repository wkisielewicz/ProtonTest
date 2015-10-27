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
  let(:fb) {Firebird_Variables.new(:gbak_path,:isql_path,:full_path,:login,:password_firebird_database,:wrong_password,:security_password)}
  $account=Account.new().create!

  #end

  it 'should correct configuration firebird' do

    @key = $account.activation_key

    cb = Capybara

    cb.register_driver :my_firefox_driver do |app|
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['browser.download.dir'] = "~/Downloads"
      profile['browser.download.folderList'] = 2 #2-the last folder specified for a download
      profile['browser.helperApps.alwaysAsk.force'] = false
      profile['browser.download.manager.showWhenStarting'] = false
      profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/octet-stream'
      profile['csvjs.disabled'] = true
      Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
    end

    cb.current_driver = :my_firefox_driver


    cb.visit('http://localhost:10555/')

    #initial proton, setup access key
    cb.visit('http://localhost:10555/')

    cb.page.find('div.col-sm-7 > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-user-access-token', :with => @key
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 6
    cb.page.find('div.button-group > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-config-database-connection-string', with: fb.full_path
    fill_in 'initial-wizard-setup-wizard-data-config-database-login', with: fb.login
    sleep 4
    fill_in 'initial-wizard-setup-wizard-data-config-database-password', with: fb.password_firebird_database
    sleep 5
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 3
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase1', with: fb.security_password
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase2', with: fb.security_password
    cb.page.find('div.button-group > button.btn-primary.btn').click
    cb.page.find('div.panel-text > button.btn-primary.btn').click
    sleep 13
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 3
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 8
    puts cb.title
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

    let(:fb) {Firebird_Variables.new(:gbak_path,:isql_path,:full_path,:login,:password_firebird_database,:wrong_password,:security_password)}

    it 'Proper restoration for a database firebird' do

      visit('http://localhost:10555/')

      visit('http://localhost:10555/')

      page.find('button.btn-default.btn').click
      page.find('div.button-group > button.btn-primary.btn').click
      sleep 5
      # page.find('panel-body').text
      #  fill_in 'main-view-restore-wizard-data-config-tools-gbak-path',               with: fb.gbak_path
      #  expect(page).to have_field('main-view-restore-wizard-data-config-tools-gbak-path', with: fb.gabk_path
      #  fill_in 'main-view-restore-wizard-data-config-tools-isql-path',               with: fb.isql_path
      fill_in 'main-view-restore-wizard-data-config-database-connection-string', with: fb.full_path
      fill_in 'main-view-restore-wizard-data-config-database-login', with: fb.login
      fill_in 'main-view-restore-wizard-data-config-database-password', with: fb.password_firebird_database
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

      @id = $account.subscription_id
      system("proton-provision destroy -i #{@id}")
    end

  end
end


##########################################
# after(:each) do
#
#   @id = @account.subscription_id
#   system("proton-provision destroy -i #{@id}")
# end
