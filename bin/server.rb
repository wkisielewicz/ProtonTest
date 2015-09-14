require 'drb/drb'
require 'rubygems'
require 'pathname'
require 'rspec/core'
require 'fileutils'
require 'open3'
require 'ostruct'
require 'io/wait'


URI = 'druby://0.0.0.0:8989'


class TestServer

#Exec who returns the exception
  def exec!(cmd)
    status = exec(cmd)
    raise "Command failed with exit status #{status.exitstatus}" unless status.exitstatus == 0
  end

#Exec who returns to standard output, will perform a test
  def exec(cmd)
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      status = wait_thr.value # Process::Status object returned.
      OpenStruct.new(exit_status: status.exitstatus, stdout: stdout.read, stderr: stderr.read)
    end
  end

#Checks if a folder exists, create destination folder, output buffer of lost files
  def upload(transfer)
    puts transfer.target_path
    FileUtils.mkdir_p(File.dirname(transfer.target_path))
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


