require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'ostruct'
require 'drb/drb'

MACHINES = [
    # {vm: 'Win8.1',
    #          initial_snapshot: 'test_firebird_2_0',
    #          hostname: '10.26.14.19',
    #          username: 'IEUser',
    #          password: 'Passw0rd!'},
    {vm: 'Win7',
     initial_snapshot: 'server_test',
     hostname: '192.168.0.111',
     #hostname: '10.26.14.20',
     username: 'IEUser',
     password: 'Passw0rd!'}]

MOTHER = {#hostname: '10.26.14.13',
          hostname: '192.168.0.101',
          username: 'kisiel',
          password: 'qE2y2Uc9Gz'}

# A remote machine.
class RemoteMachine < OpenStruct
  def ssh!(cmd, timeout = 180)
    puts "[#{self.hostname}] #{cmd}"
    Timeout::timeout(timeout) do
      begin
        Net::SSH.start(self.hostname, self.username, :password => self.password) do |ssh|
          results = ssh.exec!(cmd)
          # result = SshExec.ssh_exec!(cmd)
          # raise "SSH command failed with code #{result.exit_code}" if result.exit_code != 0
          # puts result.stdout # TODO: Raise exception on failure
          # puts result.stderr
          puts results
        end
      rescue Net::SSH::HostKeyMismatch => e
        e.remember_host!
        retry
      # rescue Exception => e
      #   puts "Error in ssh!: #{e}"
      #   puts e.backtrace
      #   raise e
      end
    end
  end

  #  def scp!(source_path, target_path)
  #    puts "[#{self.hostname}] scp #{source_path} #{target_path}"
  #    Net::SCP.start(self.hostname, self.username, :password => self.password) do |scp|
  #      # synchronous (blocking) upload; call blocks until upload completes
  #      scp.upload! source_path, target_path
  #    end
  #  end
end

# Virtual machine with clean environment for tests restored from a VB snapshot.
class TestMachine < RemoteMachine
  def initialize(mother, config)
    @mother = mother
    super(config)
  end

  def setup!
    clear
    start
  end

  # def stop!
  #   # TODO: Stop vm.
  #   begin
  #   raise @mother.ssh!("VBoxManage controlvm #{self.vm} poweroff")
  #   rescue Exception => e
  #   puts e.message
  #   puts e.backtrace.inspect
  #   end
  # end

  protected

  def clear
    # TODO: Stop if vm is running (razem z Marcinem).
    #@mother.ssh!("VBoxManage list runningvms")
    # output = @mother.ssh!("VBoxManage list runningvms")
    # if output !=0
    @mother.ssh!("VBoxManage controlvm #{self.vm} poweroff")
    # end
    @mother.ssh!("VBoxManage snapshot #{self.vm} restore #{self.initial_snapshot}")

  end


  def start
    begin
      @mother.ssh!("VBoxManage startvm #{self.vm}")
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
      raise
    end
  end
end

# A suite of tests to run on a remote test machine.
class RemoteTestSuite
  #REMOTE_UPLOAD_DIR = '/tmp/'
  REMOTE_UPLOAD_DIR = '//vboxsrv/test/'

  def initialize(test_machine)
    @vm = test_machine
  end

  def run!
    @vm.setup!
    #scp_proton
    sleep 6
    install_proton
    sleep 6
    run_all_tests
  ensure
    @vm.stop!
  end

  # protected

  # def scp_proton
  #   project_root = Pathname.new(__FILE__).dirname.dirname
  #   install_path = File.join(project_root, 'install', 'Proton+Red+Setup.exe')
  #   @vm.scp! install_path, "#{REMOTE_UPLOAD_DIR}"
  #  end
  #@mother.ssh!("VBoxManage snapshot #{self.name} take #{self.initial_snapshot}test_failure")
  def install_proton
    begin
      raise @vm.ssh!("cd #{REMOTE_UPLOAD_DIR} && ./Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT")
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  ensure
    @vm.stop!
  end

  def run_all_tests

    DRb.start_service()
    obj = DRbObject.new_with_uri("druby://#{@vm.hostname}:8989")

    obj.git_reset do
      system("cat dddd")
      # system('git fetch --all') #&& system("git reset --hard #{target_revision}")
      # #zmien sciezke na 'rspec spec/my_example_spec.rb'
      # obj.run_tests
      # test=system('rspec ProtonTest/spec/my_example_spec.rb')
      # puts "[server] status tests: #{test}"
      #
      # obj.control_snapshot
      #
      # if $?.exitstatus != 0
      #   puts "[server]Tests failure, I do snapshot"
      #   #system("VBoxManage snapshot #{self.name} take #{self.initial_snapshot}test_failure")
      #
      # else
      #   puts "[server] Tests passed, snapshot is unnecessary"
      # end
    end


    puts "[server] Wait moment I doing my job"
    gets


  ensure
    # TODO: Stop DRb service?
    DRb.stop_service
  end
end


test_machines = MACHINES.map { |config| TestMachine.new(RemoteMachine.new(MOTHER), config) }
test = RemoteTestSuite.new(test_machines[0])
test.run!

exit
#restore and run snapshot from host machine (Win8.1, Win8, Vista, Win7, Win server2012, Win server2008)
=begin
hostname = '10.26.14.13'
username = 'kisiel'
password = 'qE2y2Uc9Gz'

Net::SSH.start(hostname, username, :password => password) do |ssh|
  res = ssh.exec!('VBoxManage snapshot Win8.1firebird restore test_firebird_2_0
		               VBoxManage startvm Win8.1firebird
                   VBoxManage snapshot Vistafirebird restore test_firebird_2_0
                   VBoxManage startvm Vistafirebird
                   VBoxManage snapshot Win7firebird restore test_firebird_2_0
                   VBoxManage startvm Win7firebird
		               VBoxManage snapshot Win8firebird restore test_firebird_2_0
                   VBoxManage startvm Win8firebird
                   VBoxManage snapshot WindowsServerFirebird2012 restore test_firebird_2_0
                   VBoxManage startvm WindowsServerFirebird2012
                   VBoxManage snapshot WinServerFirebird2008 restore test_firebird_2_0
                   VBoxManage startvm WinServerFirebird2008')
  puts res
end

# call for all machines the user name IEUser
# install node and run tests in machine IEUser
# copy client.rb to my path
# run client file

hosts =['10.26.14.17', '10.26.14.20', '10.26.14.21', '10.26.14.19']
username ='IEUser'
password ='Passw0rd!'

hosts.each do |host|
  Net::SSH.start(host, username, :password => password) do |ssh|
    res = ssh.exec!('cd home/IEUser/ProtonTest/bin
                     ./Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT')

    puts res
  end

# connect windows server 2012
# install node and run tests in machine IEUser
# copy client.rb to my path
# run client file

  hostname= '10.26.14.14'
  username ='winserver'
  password ='Passw0rd!'

  Net::SSH.start(hostname, username, :password => password) do |ssh|
    res = ssh.exec!('cd home/winserver/ProtonTest/bin
                   ./Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT')

    puts res

  end

# connect windows server 2008
# install node and run tests in machine IEUser
# copy client.rb to my path
# run client file

  hostname= '10.26.14.18'
  username ='cyg_server'
  password ='Passw0rd!'

  Net::SSH.start(hostname, username, :password => password) do |ssh|
    res = ssh.exec!('cd home/cyg_server/ProtonTest/bin
                   ./Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT')

    puts res
  end
end
=end
		




