class AnimatedObject
  
  @@instances = []
  
  def initialize
    @@instances << self
  end
  
  def delete
    @@instances.delete(self)
  end
  
  def self.update_all(map, player)
    @@instances.each { |i| i.update(map, player) }
  end 
  
  def self.draw_all
    @@instances.each { |i| i.draw }
  end
  
end