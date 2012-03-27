class BadDude < AnimatedObject
  include AssetsHelper
  extend AssetsHelper

  HEIGHT = 30
  WIDTH = 15
  REACH = 20
  SPEED = 3

  def initialize(x, y, map)
    @x, @y = x, y
    @map = map
    
    @direction = :left
    @vy = 0
    
    update_image
    
    super()
  end
  
  def draw
    direction = @direction == :left ? -1 : 1
    @current_image.draw_rot(@x, @y - HEIGHT - 4, ZOrder::CptnRuby, 0, 0.5, 0, direction)
  end
  
  def can_touch?(player)
    (@x - player.x).abs < REACH && (@y - player.y).abs < REACH
  end
  
  def update(map, player)
    update_image
    add_gravity
    move_vertically
    
    if @direction == :left
      step_left
      turn_around if can_move_down?
      turn_around if !can_move_left?
    else
      step_right
      turn_around if can_move_down?
      turn_around if !can_move_right?
    end
    
    player.damage(1) if can_touch?(player)
    
  end
  
  def turn_around
    if @direction == :left
      step_right
    else
      step_left
    end
  end
  
  def step_right
    @direction = :right
    SPEED.to_i.times do
      break unless can_move_right?
      @x += 1
    end
  end
  
  def step_left
    @direction = :left
    SPEED.to_i.times do
      break unless can_move_left?
      @x -= 1
    end
  end
  
  private
  
  def update_image
    @current_image = walk_image
  end

  def add_gravity
    @vy += Game::GRAVITY
  end
  
  def move_vertically
    move_down
  end
  
  def move_down
    @vy.to_i.times do
      if can_move_down?
        @y += 1 
      else 
        @vy = 0
        break
      end
    end
  end
  
  def can_move_right?
    map_open?(@x + WIDTH + 1, @y)
  end
  
  def can_move_left?
    map_open?(@x - WIDTH - 1, @y)
  end
  
  def can_move_up?
    map_open?(@x + WIDTH, @y - HEIGHT - 1) && map_open?(@x - WIDTH, @y - HEIGHT - 1)
  end
  
  def can_move_down?
    map_open?(@x + WIDTH, @y + 1) && map_open?(@x - WIDTH, @y + 1)
  end
   
  def map_open?(x, y)
    !@map.solid?(x, y)
  end
  
  def walk_image
    BadDude.walking_images[milliseconds / 100 % 8]
  end

  def self.walking_images
    @@walking_images ||= (0..10).map do |i|
      Gosu::Image.new($window, image_path("Xdefaultfire_run0#{'%02d' % i}.gif"), false)
    end
  end
  
end