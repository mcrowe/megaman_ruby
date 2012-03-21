#!/usr/bin/env ruby

require 'drb'

class MyGame
  def restart
    $stderr.puts 'restarted'
    $stderr.flush
    load 'ctpn_ruby/game.rb'
  end
end

DRb.start_service("druby://127.0.0.1:9000", MyGame.new)
$stderr.puts "Game is ready and listening on port 9000"
$stderr.flush

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require "ctpn_ruby"

DRb.thread.join