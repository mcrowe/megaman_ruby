class Fireball < AnimatedObject
  include AssetsHelper
  
  SPEED = 10
  HEIGHT = 20
  
  def initialize(x, y, map, direction)
    @direction = direction == :right ? 1 : -1
    @image = Gosu::Image.new($window, image_path("Xarmored_hadouken004.gif"), false)
    Fireball.sound.play
    
    super(x, y, map)
  end
  
  def draw
    @image.draw(@x, @y, ZOrder::CptnRuby, @direction)
  end
  
  def update(map, player)
    @x += @direction * SPEED
    if @map.solid?(@x, @y + HEIGHT)
      delete
    end
    handle_collisions
  end
  
  def self.sound
    @@sound ||= Sound.new('39016__wildweasel__dsfirxpl.wav')
  end
  
  def handle_collisions
    AnimatedObject.handle_all_collisions(self, @x, @y)
  end
  
end