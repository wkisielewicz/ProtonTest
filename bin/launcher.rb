require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'ostruct'
require 'drb/drb'
require 'ssh-exec'
require 'pathname'

MACHINES = [
    # {vm: 'Win8.1',
    #          initial_snapshot: 'test_firebird_2_5',
    #          hostname: '10.26.14.19',
    #          hostname: '192.168.0.113'
    #          username: 'IEUser',
    #          password: 'Passw0rd!'}
    # {vm: 'Vista',
    #         initial_snapshot: 'test_firebird_2_5',
    #         hostname:  '192.168.0.119',
    #         username: 'IEUser',
    #         password: 'Passw0rd!'}
    # {vm: 'Win8',
    #         initial_snapshot: 'test_firebird_2_5',
    #         hostname:  '192.168.0.120',
    #         username: 'IEUser',
    #         password: 'Passw0rd!'}
    # {vm: 'WindowsServer2012',
    #         initial_snapshot: 'test_firebird_2_5',
    #         hostname:  '192.168.0.', <--- wpisz adres
    #         username: 'winserver',
    #         password: 'Passw0rd!'}
    # {vm: 'WinServer2008',
    #         initial_snapshot: 'test_firebird_2_5',
    #         hostname:  '192.168.0.121',
    #         username: 'Administrator',
    #         password: 'Passw0rd!'}

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
    super(config)     #arg->org.meth
  end

  def setup!
    clear
    start(wait: 120)
  end

  def stop!
    @mother.ssh!("VBoxManage controlvm #{self.vm} poweroff")
  end
#TODO:  zmiana nazw, wyci�gni�cie metody
  def running?
    output = @mother.ssh!('VBoxManage list runningvms | cut -d \" -f2').stdout
    true if output[self.vm]
  end

  def take_snapshot!(snapshot_name)
    @mother.ssh!("VBoxManage snapshot #{self.vm} take #{snapshot_name}")
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
          ssh!('echo', 40)
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
  # - Refactor code (w/ m�dry i sympatyczny Marcin).
  # - sprawdzanie czy dzia�a server za pomoc� DRB
  # - komentarze(cel dzia�ania, jak)

  def run_all_tests
    setup_upload(@test_vm.install_dir)
    install_proton
    copy_specs(@test_vm.spec_dir)
    run_tests
  end

  def setup_base_dir
    File.join(File.dirname(__FILE__), "..")
  end

  def setup_upload(target_dir)
    base_dir = setup_base_dir
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

  def run_tests
     status = @server.exec("rspec #{@test_vm.spec_dir}\\spec\\firebird_wizzard_spec.rb")
     if status.exit_code == 0
       puts "Tests passed, snapshot is unnecessary"
     else
       @test_vm.take_snapshot!("test_failure")
       puts status.stdout
       puts status.stderr
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
    @in.read(BUF_SIZE)
  end
end

DRb.start_service

test_machines = MACHINES.map { |config| TestMachine.new(RemoteMachine.new(MOTHER), config)}
test = RemoteTestSuite.new(test_machines[0])
test.run!
exit





