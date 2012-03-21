require 'rubygems'
require 'bundler'
Bundler.setup

require 'gosu'
include Gosu

class CtpnRuby
end

Dir[File.expand_path(File.dirname(__FILE__) + "/ctpn_ruby/*.rb")].each do |file|
  require file
end

Game.new.show