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


describe 'generate security key', :type => :feature, :js => true do

  let(:fb) {Firebird_Variables.new(:gbak_path,:isql_path,:full_path,:login,:password_firebird_database,:wrong_password,:security_password)}


  it 'correct generate security key'do

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
    cb.find(:xpath, "//div[@id='app']/div/div[2]/div/ul/li[3]/a").click
    #cb.page.find('li.tab-danger. > a').click # znajdz nowy selektor
    cb.page.find('div.tab-contents > button.btn-primary.btn').click
    fill_in 'admin-dashboard-encryption-wizard-data-config-encryption-passphrase1', with: fb.security_password
    fill_in 'admin-dashboard-encryption-wizard-data-config-encryption-passphrase2', with: fb.security_password
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    cb.page.find('#admin-dashboard-encryption-wizard-data-config-encryption-generate-understand').click

    #cb.page.find('label > strong').click
    cb.page.find('#admin-dashboard-encryption-wizard-data-config-encryption-generate-accepted').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    sleep 5
    cb.page.find('div.panel-text > button.btn-primary.btn').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    cb.page.find('div.button-group > button.btn-primary.btn').click
    #cb.page.driver.render('./screenshot/generate_security_key.png', :full => true)

  end
end