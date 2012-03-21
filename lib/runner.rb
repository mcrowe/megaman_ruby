require 'drb'

class Runner
  
  def start
    $stderr.puts "Game is ready and listening on port 9000"
    $stderr.flush
    $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
    load 'cptn_ruby.rb'
  end
  
  def restart
    $stderr.puts 'restarted'
    $stderr.flush
    load 'ctpn_ruby/game.rb'
  end
  
end

runner = Runner.new
DRb.start_service("druby://127.0.0.1:9000", runner)
runner.start

DRb.thread.join
