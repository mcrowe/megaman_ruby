#!/usr/bin/env ruby -w
require 'drb'

DRb.start_service

def restart
  # attach to the DRb server via a URI given on the command line
  remote_thing = DRbObject.new nil, 'druby://127.0.0.1:9000'
  remote_thing.restart
end

watch( '^lib/ctpn_ruby/.*\.rb' )  {|md| $stderr.puts 'Restarting the game'; restart }  

$stderr.puts 'Watching lib files so we can restart the game.'