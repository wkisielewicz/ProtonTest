# Automated tests for Proton Red

### This system is based on the action of DRB server.

## Major dependencies 

* Phantomjs with the repaired bug to upload files/poltergiest

           https://www.dropbox.com/s/u71vipap8bnm72u/windows-x86_64-phantomjs.exe?dl=0
           
* Ruby 2.0.0 or higher and devkit
           
           http://rubyinstaller.org/downloads/
           
* selenium webdriver
* capybara webkit 

           https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit
            
* rspec

## How does it work?

This system allows to manage virtual machines, preparing a test environment by copying the necessary files and run tests.
Launcher is arranged on the build machine communicates, a server that is placed on the target test machine.

## Tests

Tests are run by rspec, including test cases for major functionality Proton Red.
           
      
     
     
     