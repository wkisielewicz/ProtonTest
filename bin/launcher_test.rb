require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'ostruct'
require 'drb/drb'
require 'ssh-exec'

MACHINES = [
    # {vm: 'Win8.1',
    #          initial_snapshot: 'test_firebird_2_0',
    #          hostname: '10.26.14.19',
    #          username: 'IEUser',
    #          password: 'Passw0rd!'},
    {vm: 'Win7',
     initial_snapshot: 'server_test3',
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
        Net::SSH.start(self.hostname, self.username, password: self.password, timeout: timeout) do |ssh|
          result = SshExec.ssh_exec!(ssh, cmd)
          show_ssh_result(result)
          raise "SSH command failed with code #{result.exit_status}" if result.exit_status != 0
          result
        end
      rescue Net::SSH::HostKeyMismatch => e
        e.remember_host!
        retry
      end
    end
  end

  def scp!(source_path, target_path)
    puts "[#{self.hostname}] scp #{source_path} #{target_path}"
    Net::SCP.start(self.hostname, self.username, :password => self.password) do |scp|
      # synchronous (blocking) upload; call blocks until upload completes
      scp.upload! source_path, target_path
    end
  end

  protected

  def show_ssh_result(result)
    stdout_prefix = "==>"
    stderr_prefix = "1=>"
    puts result.stdout.split("\n").map { |line| "#{stdout_prefix} #{line}" }.join("\n") unless result.stdout.strip.empty?
    puts result.stderr.split("\n").map { |line| "#{stderr_prefix} #{line}" }.join("\n") unless result.stderr.strip.empty?
  end
end

# Virtual machine with clean environment for tests restored from a VB snapshot.
class TestMachine < RemoteMachine
  def initialize(mother, config)
    @mother = mother
    super(config)
  end

  def setup!
    clear
    start(wait: 120)
  end

  def stop!
    @mother.ssh!("VBoxManage controlvm #{self.vm} poweroff")
  end

  def running?
    output = @mother.ssh!('VBoxManage list runningvms').stdout
    true if output[self.vm]
  end

  protected

  def clear
    stop! if running?
    restore_from(self.initial_snapshot)
  end

  def restore_from(snapshot)
    @mother.ssh!("VBoxManage snapshot #{self.vm} restore #{snapshot}")
  end

  def start(options = {})
    @mother.ssh!("VBoxManage startvm #{self.vm}")
    wait = options[:wait].to_i
    wait_for_ssh(wait) if wait > 0
  end

  def wait_for_ssh(wait)
    Timeout::timeout(wait) do
      while true
        ignore_exceptions do
          ssh!('echo', 30)
          return
        end
      end
    end
  rescue Timeout::Error
    raise Timeout::Error, "VM's ssh server not ready within #{wait}s"
  rescue Errno::ETIMEDOUT
    raise Timeout::Error, "VM's ssh server not ready within #{wait}s"
  end

  def ignore_exceptions
    yield
  rescue
  end
end

# A suite of tests to run on a remote test machine.
class RemoteTestSuite
  #REMOTE_UPLOAD_DIR = '/tmp/'
  REMOTE_UPLOAD_DIR = '//vboxsrv/test/'

  def initialize(test_machine)
    @test_vm = test_machine
  end

  def run!
    @test_vm.setup!
    #scp_proton
    install_proton
    run_all_tests
  end

  # protected

  # def scp_proton
  #   project_root = Pathname.new(__FILE__).dirname.dirname
  #   install_path = File.join(project_root, 'install', 'Proton+Red+Setup.exe')
  #   @test_vm.scp! install_path, "#{REMOTE_UPLOAD_DIR}"
  #  end
  #@mother.ssh!("VBoxManage snapshot #{self.name} take #{self.initial_snapshot}test_failure")
  def install_proton
    @test_vm.ssh!("cd #{REMOTE_UPLOAD_DIR} && ./Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT")
  end

  # Main TODO
  # - Benchmark upload of large files.
  # - Copy spec/ dir to server to avoid having to use git.
  # - Run spec on server using #exec.
  # - Rewrite install_proton using #exec.
  # - Use #upload to copy setup to avoid shared folders.
  # - Refactor code (w/ upierdliwy Marcin).

  def run_all_tests

    DRb.start_service()
    server = DRbObject.new_with_uri("druby://#{@test_vm.hostname}:8989")


    # Copy specs using upload.
    # Dir.glob('../spec/**/*') do |path|
    #   server.upload(FileTransfer.new(path, ....?))
    # end
    # # Run specs using exec
    # server.exec('rspec ProtonTest/spec/my_example_spec.rb')
    # If exit code not zero, create snapshot.

    return
    # server.git_reset do
    #   system("ls")
    #   system('git fetch --all') #&& system("git reset --hard #{target_revision}")
    #   #zmien sciezke na 'rspec spec/my_example_spec.rb'
    #   server.run_tests
    #   test=system('rspec ProtonTest/spec/my_example_spec.rb')
    #   puts "[server] status tests: #{test}"
    #
    #   server.control_snapshot
    #
    #   if $?.exitstatus != 0
    #     puts "[server]Tests failure, I do snapshot"
    #     #system("VBoxManage snapshot #{self.name} take #{self.initial_snapshot}test_failure")
    #
    #   else
    #     puts "[server] Tests passed, snapshot is unnecessary"
    #   end
    # end


    puts "[server] Wait moment I doing my job"
    gets


  ensure
    # TODO: Stop DRb service?
    DRb.stop_service
  end
end

class FileTransfer
  include DRb::DRbUndumped

  def initialize(source_path, target_path)
    @in = File.open(source_path, 'rb')
    @target_path = target_path
  end

  def target_path
    @target_path
  end

  BUF_SIZE = 256 * 1024
  def read
    x = @in.read(BUF_SIZE)
    x
  end
end

# test_machines = MACHINES.map { |config| TestMachine.new(RemoteMachine.new(MOTHER), config) }
# test = RemoteTestSuite.new(test_machines[0])
# test.run!
DRb.start_service()
obj = DRbObject.new_with_uri("druby://localhost:8989")
obj.upload(FileTransfer.new("install/Proton+Red+Setup.exe", "setup.exe"))
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
		




