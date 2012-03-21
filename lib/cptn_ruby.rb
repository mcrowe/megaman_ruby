require 'rubygems'
require 'bundler'
Bundler.setup

require 'gosu'

include Gosu

module CptnRuby
  
  def self.start
    puts 'Starting Captain Ruby.'
    reload
    Game.new.show
  end
  
  def self.reload
    puts 'Loading Code.'
    Dir[File.expand_path(File.dirname(__FILE__) + "/cptn_ruby/*.rb")].each do |file|
      load file
    end  
  end
  
end