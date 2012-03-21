require 'drb'
require File.expand_path(File.dirname(__FILE__) + '/lib/cptn_ruby.rb')

SERVICE = 'druby://127.0.0.1:9000'

task :run do
  $VERBOSE = nil
  DRb.start_service(SERVICE, CptnRuby)
  puts "DRB service started at #{SERVICE}."
  CptnRuby.start
  DRb.thread.join
end

task :reload do
  DRb.start_service
  DRbObject.new(nil, SERVICE).reload
end

task :watch do
  system('watchr reload.watchr')
end