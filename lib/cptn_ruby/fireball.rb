class Fireball
  include AssetsHelper
  
  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
    @image = Gosu::Image.new($window, image_path("Xarmored_hadouken004.gif"), false)
    Fireball.sound.play
  end
  
  def draw
    d = @direction == :right ? 1 : -1
    @image.draw(@x, @y, ZOrder::CptnRuby, d)
  end
  
  def update
    if @direction == :right
      @x += 10 
    else
      @x -= 10
    end
  end
  
  def self.sound
    @@sound ||= Sound.new('39016__wildweasel__dsfirxpl.wav')
  end
  
  
end