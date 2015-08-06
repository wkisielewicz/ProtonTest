#require 'rspec'
require_relative 'spec_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'


Capybara.javascript_driver = :poltergeist

describe 'Setting up Firebird Wizzard', :type => :feature, :js => true do

  it 'should correct configuration firebird' do

    visit('http://localhost:10555/')

    click_link('Baza danych')
    fill_in 'config-tools-gbak-path', :with=> 'C:\Program Files\Firebird\Firebird_2_1\bin\gbak.exe'
    fill_in 'config-tools-isql-path', :with=> 'C:\Program Files\Firebird\Firebird_2_1\bin\isql.exe'
    fill_in 'config-database-connection-string', :with=> 'C:\Program Files\Firebird\Firebird_2_1\examples\empbuild\EMPLOYEE.FDB'
    fill_in 'config-database-login', :with=> 'SYSDBA'
    fill_in 'config-database-password', :with=> 'masterkey'
    page.find('div.col-sm-7 > button.btn-primary.btn').click
    expect(page).to have_no_content 'Error'
    page.driver.render('./screenshot/firebird_wizzard.png', :full => true)

  end
end



