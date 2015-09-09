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

  # TODO: Return OpenStruct with fields:
  # - exit_status
  # - stdout
  # - stderr
  def exec(cmd)
    `#{cmd}`
  end

  def upload(transfer)
    puts transfer.target_path
    #FileUtils.mkdir_p(File.dirname(transfer.target_path))
    File.open(transfer.target_path, 'wb+') do |out|
      while (buf = transfer.read)
        puts "Read #{buf.size}"
        out.write(buf)
      end
    end
  end
end

FRONT_OBJECT = TestServer.new
DRb.start_service(URI, FRONT_OBJECT)
DRb.thread.join