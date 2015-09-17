require 'rspec'
require 'provision'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'


Capybara.javascript_driver = :poltergeist

describe 'Setting up Firebird Wizzard', :type => :feature, :js => true do

   before(:each) do
     @account=Acount.create!(user_email,admin_email,licence)
 end
after(:each) do
  @account.destroy!

end
  it 'should correct configuration firebird' do


  @account.activation_key

    visit('http://localhost:10555/')

    #initial proton, setup acces key
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    fill_in 'initial-wizard-setup-wizard-data-user-access-token', :with=> @account.activation.key
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    #security key
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase1', :with=> 'test'
    fill_in 'initial-wizard-setup-wizard-data-config-encryption-passphrase2', :with=> 'test'
    page.find('div.button-group > button.btn-primary.btn').click
    page.find('div.panel-text > button.btn-primary.btn').click
    page.find('initial-wizard-setup-wizard-data-config-encryption-generate-understand').click
    page.find('initial-wizard-setup-wizard-data-config-encryption-generate-accepted').click
    page.find('div.button-group > button.btn-primary.btn').click
    #firebird settings tools
    fill_in 'config-tools-gbak-path', :with=> 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe'
    fill_in 'config-tools-isql-path', :with=> 'C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe'
    fill_in 'config-database-connection-string', :with=> 'C:\Program Files\Firebird\Firebird_2_5\examples\empbuild\EMPLOYEE.FDB'
    fill_in 'config-database-login', :with=> 'SYSDBA'
    fill_in 'config-database-password', :with=> 'masterkey'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    page.find('div.button-group > button.btn-primary.btn').click
    expect(page).to have_no_content 'Error'
     page.driver.render('./screenshot/firebird_wizzard.png', :full => true)

  end
 end




