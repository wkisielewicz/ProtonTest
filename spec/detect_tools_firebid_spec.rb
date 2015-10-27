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

describe 'detect tools firebird',  :type => :feature, :js => true do

  let(:fb) {Firebird_Variables.new(:gbak_path,:isql_path,:full_path,:login,:password_firebird_database,:wrong_password,:security_password)}

  it 'should detect tools  firebird database' do

    visit('http://localhost:10555')
    find(:xpath, "//div[@id='app']/div/div[2]/div/ul/li[2]/a/span/span").click

    expect(page).to have_field('config-tools-isql-path', with: fb.isql_path)
    expect(page).to have_field('config-tools-gbak-path', with: fb.gbak_path)

  end
end