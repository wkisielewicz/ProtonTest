require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'ostruct'
require 'drb/drb'
require 'ssh-exec'
require 'pathname'

MACHINES = [
    # {vm: 'Win8.1',
    #          initial_snapshot: 'test_firebird_2_0',
    #          hostname: '10.26.14.19',
    #          username: 'IEUser',
    #          password: 'Passw0rd!'},
    {vm: 'Win7',
     initial_snapshot: 'server_test4',
     hostname: '192.168.0.111',
     #hostname: '10.26.14.20',
     username: 'IEUser',
     password: 'Passw0rd!',
     install_dir: 'C:\\ProtonTest',
     spec_dir: 'C:\\ProtonTest'}]

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

  def take_snapshot!(snapshot_name)
    @mother.ssh!("VBoxManage snapshot #{self.vm} take test_failure")
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
  #UPLOAD_DIR = @test_vm.spec_dir

  # Requires DRb sevice to be started.
  def initialize(test_machine)
    @test_vm = test_machine
    @server = DRbObject.new_with_uri("druby://#{@test_vm.hostname}:8989")
  end

  def run!
    #@test_vm.setup!
    run_all_tests
  end


  # Main TODO
  # - Benchmark upload of large files. +
  # - Copy spec/ dir to server to avoid having to use git.
  # - Run spec on server using #exec.
  # - Rewrite install_proton using #exec.
  # - Use #upload to copy setup to avoid shared folders.
  # - Refactor code (w/ m¹dry i sympatyczny Marcin).

  def run_all_tests
    #setup_upload(@test_vm.install_dir)
    #install_proton
    copy_specs(@test_vm.spec_dir)
    run_tests
  end

  def setup_upload(target_dir)
    base_dir = File.join(File.dirname(__FILE__), "..")
    setup = File.join(base_dir, 'install/**/*')
    Dir.glob(setup) do |source_path|
      target_path = File.join(target_dir, Pathname.new(source_path).relative_path_from(Pathname.new(base_dir)).to_s)
      @server.upload(FileTransfer.new(source_path, target_path))
    end
  end

  def install_proton
    @server.exec(" #{@test_vm.install_dir}\\install\\Proton+Red+Setup.exe /SP- /NORESTART /VERYSILENT")
  end

  def copy_specs(target_dir)
    base_dir = File.join(File.dirname(__FILE__), "..")
    specfiles = File.join(base_dir, 'spec/**/*')
    Dir.glob(specfiles) do |source_path|
      target_path = File.join(target_dir, Pathname.new(source_path).relative_path_from(Pathname.new(base_dir)).to_s)
      if File.file?(source_path)
        puts "#{source_path} => #{target_path}"
        @server.upload(FileTransfer.new(source_path, target_path))
      end
    end
  end

  def run_tests
     status = @server.exec("rspec #{@test_vm.spec_dir}\\spec\\firebird_wizzard.rb")
     if status.exit_code == 0
       @test_vm.take_snapshot!("test_failure")
       puts "Tests passed, snapshot is unnecessary"
     else
       puts status.stdout
       puts status.stderr
       puts "fail"
     end
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

DRb.start_service

test_machines = MACHINES.map { |config| TestMachine.new(RemoteMachine.new(MOTHER), config)}
test = RemoteTestSuite.new(test_machines[0])
# test.copy_specs("C:\\ProtonTest2")
test.run!
#  DRb.start_service()
#  obj = DRbObject.new_with_uri("localhost:8989")
#  obj.upload(FileTransfer.new("install/Proton+Red+Setup.exe", "setup.exe"))
 #exit





