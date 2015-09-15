require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'ostruct'
require 'drb/drb'
require 'timeout'
require 'ssh-exec'
require 'pathname'
require 'io/wait'


#Access data defining attributes for each virtual machine
MACHINES = [
     # {vm: 'Win8.1',
     #          #initial_snapshot: 'test_firebird_2_0_server',
     #          initial_snapshot: 'test_firebird_2_5_server',
     #          hostname: '192.168.0.113',
     #          username: 'IEUser',
     #          password: 'Passw0rd!',
     #          install_dir: 'C:\\ProtonTest',
     #          spec_dir: 'C:\\ProtonTest'}
    # {vm: 'Vista', <-- no active
    #         initial_snapshot: 'test_firebird_2_5',
    #         hostname:  '192.168.0.119',
    #         username: 'IEUser',
    #         password: 'Passw0rd!',
    #         install_dir: 'C:\\ProtonTest',
    #         spec_dir: 'C:\\ProtonTest'}
     {vm: 'Win8',
             initial_snapshot: 'test_firebird_2_5_server',
             #initial_snapshot: 'test_firebird_2_0_server',
             hostname:  '192.168.0.120',
             username: 'IEUser',
             password: 'Passw0rd!',
             install_dir: 'C:\\ProtonTest',
             spec_dir: 'C:\\ProtonTest'}]
    # {vm: 'WindowsServer2012',
    #         initial_snapshot: 'test_firebird_2_5_server',
    #         #initial_snapshot: 'test_firebird_2_0_server',
    #         hostname:  '192.168.0.117',
    #         username: 'winserver',
    #         password: 'Passw0rd!',
    #         install_dir: 'C:\\ProtonTest',
    #         spec_dir: 'C:\\ProtonTest' }
    # {vm: 'WinServer2008',
    #         initial_snapshot: 'test_firebird_2_5',
    #         hostname:  '192.168.0.121',
    #         username: 'Administrator',
    #         password: 'Passw0rd!',
    #         install_dir: 'C:\\ProtonTest',
    #         spec_dir: 'C:\\ProtonTest'}

    # {vm: 'Win7', <--no active
    #  initial_snapshot: 'firebird_2_0_server',
    #  hostname: '192.168.0.111',
    #  #hostname: '10.26.14.20',
    #  username: 'IEUser',
    #  password: 'Passw0rd!',
    #  install_dir: 'C:\\ProtonTest',
    #  spec_dir: 'C:\\ProtonTest'}]

MOTHER = {#hostname: '10.26.14.13',
          hostname: '192.168.0.101',
          username: 'kisiel',
          password: 'qE2y2Uc9Gz'}

# A remote machine, define ssh, raise exception when commands failed
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

  protected

# Show stdout and stderr with ssh
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

#Load a clean snapshot and its start
  def setup!
    clear
    start(wait: 120)
  end

#Stop Virtual Machine
  def stop!
    @mother.ssh!("VBoxManage controlvm #{self.vm} poweroff")
  end

#Verify that the target snapshot is running
  def running?
    output = @mother.ssh!('VBoxManage list runningvms').stdout
    true if output["\"#{self.vm}\""]
  end

#Making a snapshot in the case of failing tests
  def take_snapshot!(snapshot_name)
    @mother.ssh!("VBoxManage snapshot #{self.vm} take #{snapshot_name}")
  end

  # protected

#Stop if target machine is running
  def clear
    stop! if running?
    restore_from(self.initial_snapshot)
  end

#Restore snapshot with test environment
  def restore_from(snapshot)
    @mother.ssh!("VBoxManage snapshot #{self.vm} restore #{snapshot}")
  end

#Check server drb status, start target Virtual Machine
  def start(options = {})
    @mother.ssh!("VBoxManage startvm #{self.vm}")
    wait = options[:wait].to_i
    wait_for_server(wait) if wait > 0
  end

  def wait_for_server(wait = 30)
    url = "druby://#{self.hostname}:8989"
    puts "Waiting for #{url}..."
    server = DRbObject.new_with_uri(url)
    Timeout::timeout(wait) do
      while true
        # ignore_exceptions do
          puts "wait"
          return if server.ready?
          sleep(1)
        # end
      end
    end
  rescue Timeout::Error
    raise Timeout::Error, "VM's test server not ready within #{wait}s"
  rescue Errno::ETIMEDOUT
    raise Timeout::Error, "VM's test server not ready within #{wait}s"
  end

  def ignore_exceptions
    yield
  rescue
  end
end

# A suite of tests to run on a remote test machine.
class RemoteTestSuite

# Requires DRb sevice to be started.
  def initialize(test_machine)
    @test_vm = test_machine
    @server = DRbObject.new_with_uri("druby://#{@test_vm.hostname}:8989")
  end


#Start Virtual Machine with initial snapshot, copy and run all dependency files necessary for testing
  def run!
    @test_vm.setup!
    run_all_test_dependency
  end


# Main TODO
# - Refactor code (w/ m¹dry i sympatyczny Marcin).
# - sprawdzanie czy dzia³a server za pomoc¹ DRB
# - komentarze(cel dzia³ania, jak)
# - zmiana nazw

#Setup all method necessary for testing
  def run_all_test_dependency
    copy_proton_exe(@test_vm.install_dir)
    install_proton
    copy_specs(@test_vm.spec_dir)
    run_spec_tests
  end

  def setup_base_dir
    File.join(File.dirname(__FILE__), "..")
  end

#Copy proton exe from install dir(base_dir), and throwing to the target folder
  def copy_proton_exe(target_dir)
    base_dir = setup_base_dir
    setup = File.join(base_dir, 'install/**/*')
    Dir.glob(setup) do |source_path|
      target_path = File.join(target_dir, Pathname.new(source_path).relative_path_from(Pathname.new(base_dir)).to_s)
      @server.upload(FileTransfer.new(source_path, target_path))
    end
  end

#Install proton in silent mode, omission windows during installation
  def install_proton
    @server.exec(" #{@test_vm.install_dir}\\install\\Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT")
  end

#Copy specs from install dir(base_dir), and throwing to the target folder.Omission folder - copying only the files using File.file?()
  def copy_specs(target_dir)
    base_dir = setup_base_dir
    specfiles = File.join(base_dir, 'spec/**/*')
    Dir.glob(specfiles) do |source_path|
      target_path = File.join(target_dir, Pathname.new(source_path).relative_path_from(Pathname.new(base_dir)).to_s)
      if File.file?(source_path)
        puts "#{source_path} => #{target_path}"
        @server.upload(FileTransfer.new(source_path, target_path))
      end
    end
  end

#Run rspec tests, when exit code != take snapshot, print stdout and stderr
  def run_spec_tests
    status = @server.exec("rspec #{@test_vm.spec_dir}\\spec\\my_example_spec.rb")
    if status.exit_code == 0
      puts "Tests passed, snapshot is unnecessary"
    else
      @test_vm.take_snapshot!("test_failure")
      puts status.stdout
      puts status.stderr
    end
  end
end

# Class specifies the buffer size of transmitted files, defines variables for target_path and IO mode (read,binary)
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
    @in.read(BUF_SIZE)
  end
end

DRb.start_service

   test_machines = MACHINES.map { |config| TestMachine.new(RemoteMachine.new(MOTHER), config)}
    test = RemoteTestSuite.new(test_machines[0])
    test.run!
    exit


# remote_machine = TestMachine.new(RemoteMachine.new(MOTHER), MACHINES.first)
# remote_machine.wait_for_server(5)
#  s = DRbObject.new_with_uri("druby://192.168.0.111:8989")
#  puts s.ready?
#local_machine = TestMachine.new(RemoteMachine.new(MOTHER), MACHINES.first.merge(hostname: "localhost"))



DRb.stop_service

