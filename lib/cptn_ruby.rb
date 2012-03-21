require 'rubygems'
require 'bundler'
Bundler.setup

require 'gosu'

class CptnRuby
  include Gosu
  
  def initialize
    load_source_files
    Game.new.show
  end
  
  def reload
    load_source_files
  end
  
  private
  
  def load_source_files
    Dir[File.expand_path(File.dirname(__FILE__) + "/cptn_ruby/*.rb")].each do |file|
      load file
    end  
  end
  
end