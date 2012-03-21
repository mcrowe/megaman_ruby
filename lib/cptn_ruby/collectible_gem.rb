class CollectibleGem
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x, @y = x, y
  end
  
  def draw
    @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
  end
  
  def empty?
    size == 0
  end
  
end