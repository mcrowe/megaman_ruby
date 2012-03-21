require 'drb'

task :run do

  DRb.start_service("druby://127.0.0.1:9000", CptnRuby.new)
  $stderr.puts "Game is ready and listening on port 9000"
  $stderr.flush
  DRb.thread.join

end

task :restart do
  DRb.start_service
  cptn_ruby = DRbObject.new nil, 'druby://127.0.0.1:9000'
  cptn_ruby.reload
end