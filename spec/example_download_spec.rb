require 'capybara/dsl'
require 'selenium-webdriver'

cb = Capybara

cb.register_driver :my_firefox_driver do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['browser.download.dir'] = "~/Downloads"
  profile['browser.download.folderList'] = 2
  profile['browser.helperApps.alwaysAsk.force'] = false
  profile['browser.download.manager.showWhenStarting'] = false
  profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/vnd.ms-excel'
  profile['csvjs.disabled'] = true
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
end

cb.current_driver = :my_firefox_driver

# just to check that we are reaching the correct URL
cb.visit "https://www.google.com/finance/historical?q=NYSE:IBM&startdate=Jan+1%2C+1980&enddate=Sep+18%2C+2014&num=30"
sleep(3)
# attempt a CSV download
cb.visit "https://www.google.com/finance/historical?q=NYSE:IBM&startdate=Jan+1%2C+1980&enddate=Sep+18%2C+2014&output=csv"
sleep(15)