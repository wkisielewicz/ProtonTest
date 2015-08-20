require 'drb/drb'

# The URI for the server to connect to


URI = 'druby://0.0.0.0:8787'

######## Git and run tests #####################
class TestServer

  def initialize
    @url = 'git@github.com:wkisielewicz/ProtonTest.git'
    @revision = 'master'
  end

  def git_clone
    system("git clone #{@url}")
  end

  def git_reset
    system('git fetch --all')
    system("git reset --hard #{target_revision}")
  end

  def target_revision
    system("rev-parse #{@revision}")
  end

  def run_tests
    ref=system('cd ProtonTest/spec && rspec backup_firebird_spec.rb')
    puts ref
  end

  ####### snapshot when exit code =! 0 or true ######

  def control_snapshot

    if $?.exitstatus != 0
      puts "OMG FAIL :)"
      #system()

    else
      puts "OK "
    end



  end

#private
   def git_tests
     git_clone
     git_reset
     target_revision
     run_tests
     control_snapshot

     #git clone your-repo tmp && mv tmp/.git . && rm -rf tmp && git reset --hard
  end
end

FRONT_OBJECT=TestServer.new

$SAFE = 1   # disable eval() and friends --security

DRb.start_service(URI, FRONT_OBJECT)

DRb.thread.join

