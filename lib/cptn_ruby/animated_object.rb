class AnimatedObject
  
  @@instances ||= []

  attr_reader :x, :y
  
  def initialize(x, y, map)
    @x = x
    @y = y
    @map = map
    
    @vy = 0
    
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
  
  def self.handle_all_collisions(target, x, y)
    @@instances.each do |instance|
      
      if (instance.x - x).abs < 10 && (instance.y - 40 - y).abs < 20
        if instance.respond_to?(:collide)
          instance.collide(target)
        end
      end
        
    end
      
  end
  
  def self.clear
    @@instances = []
  end
  
end