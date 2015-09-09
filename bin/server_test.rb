require 'drb'
require 'pathname'

URI = 'druby://0.0.0.0:8989'

class TestServer
  def initialize
    @branch = 'master'
    project_root = Pathname.new(__FILE__).dirname.dirname
    Dir.chdir(project_root)
  end

  def evaluate(ruby_code)
    eval(ruby_code)
  end

  def exec(cmd)
    system(cmd)
  end

  def upload(file)
    file.read
  end
end

FRONT_OBJECT = TestServer.new
DRb.start_service(URI, FRONT_OBJECT)
DRb.thread.join