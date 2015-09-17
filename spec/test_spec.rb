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

    A=b echo $a


  end
end