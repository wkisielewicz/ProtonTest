require 'drb/drb'
require 'pathname'

# The URI for the server to connect to


URI = 'druby://0.0.0.0:8989'

######## Git and run tests #####################
class TestServer

  def initialize
    @branch = 'master'
    project_root = Pathname.new(__FILE__).dirname.dirname
    Dir.chdir(project_root)
  end

  def git_reset
    system('git fetch --all')
    system("git reset --hard #{target_revision}")
  end

  def target_revision
    system("rev-parse #{@branch}")
  end

  def run_tests
    ref = system('rspec spec/my_example_spec.rb')
    puts ref
  end

  ####### snapshot when exit code =! 0 or true ######

 # def control_snapshot
  #TODO: Snapshot when exit status !=0
  def control_snapshot
    if $?.exitstatus != 0
      system("VBoxManage snapshot #{self.vm} take #{self.initial_snapshot}.Testowy --description Snapshot")
    else
      puts "OK "
    end
 end

#  if $?.exitstatus != 0
#   puts "OMG FAIL :)"
#system()

# else
#   puts "OK "
# end
# end

  def git_tests
    git_reset
    run_tests
    control_snapshot

  end
end

FRONT_OBJECT=TestServer.new

$SAFE = 1 # disable eval() and friends --security

DRb.start_service(URI, FRONT_OBJECT)

DRb.thread.join

