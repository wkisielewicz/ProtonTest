require 'rubygems'
require 'net/ssh'
require 'ostruct'
require 'drb/drb'

MACHINES = [{vm: 'Win8.1',
             initial_snapshot: 'test_firebird_2_0',
             hostname: '10.26.14.19',
             username: 'IEUser',
             password: 'Passw0rd!',
             install_dir: 'home/IEUser/ProtonTest/bin'},
            {vm: 'Win7',
             initial_snapshot: 'test_firebird_2_0_server',
             hostname: '10.26.14.20',
             username: 'IEUser',
             password: 'Passw0rd!',
             install_dir: 'home/IEUser/ProtonTest/bin'}]

MOTHER = {hostname: '10.26.14.13',
          username: 'kisiel',
          password: 'qE2y2Uc9Gz'}

class VM < OpenStruct
  def ssh!(cmd)
    puts "[#{self.hostname}] #{cmd}"
    Net::SSH.start(self.hostname, self.username, :password => self.password) do |ssh|
      res = ssh.exec!(cmd)
      puts res # TODO: Raise exception on failure
    end
  end
end

class TestMachine < VM
  def initialize(mother, config)
    @mother = mother
    super(config)
  end

  def setup!
    clear
    start
    install_proton
  end

  protected

  def clear
    # TODO: Stop if vm is running.
    @mother.ssh!("VBoxManage snapshot #{self.vm} restore #{self.initial_snapshot}")
  end

  def start
    @mother.ssh!("VBoxManage startvm #{self.vm}")
  end

  def install_proton
    # TODO: Scp proton installation exec.
    self.ssh!("cd #{self.install_dir} && ./Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT")
  end

  ####load server###
  def server_load
   sp
  end
end

test_machines = MACHINES.map {|config| TestMachine.new(VM.new(MOTHER), config)}
test_machines[1].setup!

class RemoteTestSuite
  def initialize(test_machine)
    @vm = test_machine
  end
  def run!
    @vm.setup!
    run_all_tests
  end

  protected

  def run_all_tests
    DRb.start_service
    tr = DRbObject.new_with_uri("druby://@vm.hostname:8787")
    puts tr.git_tests
  ensure
    # TODO: Stop DRb service?
  end
end

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
		




