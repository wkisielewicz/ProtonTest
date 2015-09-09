require 'drb'
require 'pathname'


URI = 'druby://0.0.0.0:8989'
$callback = nil

class TestServer

  def initialize
    @branch = 'master'
    project_root = Pathname.new(__FILE__).dirname.dirname
    Dir.chdir(project_root)
  end

  def evaluate(ruby_code)
    eval(ruby_code)
  end

  def git_reset(&reset)
    $callback = reset
  end

  def run_tests(&test)
    $callback = test
  end

  def control_snapshot(&snapshot)
    $calback = snapshot
  end
end

FRONT_OBJECT = TestServer.new

DRb.start_service(URI, FRONT_OBJECT)

begin
  loop do
    $callback.call if $callback
    sleep 1
  end
rescue DRb::DRbConnError
  puts "client is gone, no connection"
end

DRb.thread.join