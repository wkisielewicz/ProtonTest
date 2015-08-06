require 'rspec'
require '../change_harmonogram'

describe 'change harmonogram' do
#, :type => :feature do

  #before :each do

  it 'change harmonogram' do
    #change harmonogram == ChangeHarmonogram.new
    #visit 'http://localhost:10555'
      check 'config-schedule-monday'
      click_button 'Zapisz'
      expect(page).to have_content 'Success'
    end
  end

