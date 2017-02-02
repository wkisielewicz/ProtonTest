require_relative 'spec_helper'

Capybara.javascript_driver = :poltergeist


describe 'performing backup database firebird', :type => :feature, :js => true do

  before(:each) do

    visit('http://localhost:10555')

  end

  it 'make a correct copy of the data for the database firebird' do
    page.find('div.small-box.bg-grey-blue.well', wait: 10).click
    page.find('button.btn-primary.btn', wait: 6).click
    expect(page).to have_css ('div.messenger-message.message.alert.succcess.message-success.alert-success')
    page.driver.render('./screenshot/backup_firebird.png', :full => true)
  end
end
