class Player
  include AssetsHelper

  GRAVITY = 1.0
  HEIGHT = 45
  WIDTH = 25
  JUMP_SPEED = -30
  REACH = 50
  SPEED = 5

  attr_reader :x, :y, :score

  def initialize(x, y, map)
    @x, @y = x, y
    @direction = :left
    @stepping = false
    @vy = 0
    @map = map
    @jump_sound = Sound.new('boink.wav')
    @standing_image, @walk_image_1, @walk_image_2, @jump_image = *Image.load_tiles($window, image_path('cptn_ruby.png'), 50, 50, false)
    @current_image = @standing_image    
  end
  
  def draw
    direction = @direction == :left ? -1 : 1
    @current_image.draw(@x + direction * WIDTH, @y - HEIGHT - 4, ZOrder::CptnRuby, - direction * 1.0, 1.0)
  end
  
  def update
    update_image
    add_gravity
    move_vertically
    @stepping = false
  end
  
  def jump
    unless can_move?(0, 1)
      @vy = JUMP_SPEED
      @jump_sound.play
    end
  end
  
  def step_right
    @direction = :right
    @stepping = true
    SPEED.times do
      break unless can_move?(1, 0)
      @x += 1
    end
  end
  
  def step_left
    @direction = :left
    @stepping = true
    SPEED.to_i.times do
      break unless can_move?(-1, 0)
      @x -= 1
    end
  end
  
  def collect_gems
    old_gem_count = @map.gems.size
  
    @map.gems.reject! { |g| can_collect?(g.x, g.y) }
    
    old_gem_count - @map.gems.size
  end
  
  private

  def can_move?(d_x, d_y)
    top_can_move?(d_x, d_y) && bottom_can_move?(d_x, d_y)
  end
  
  def update_image
    @current_image = if @vy < 0
      @jump_image
    elsif @stepping
      walk_image
    else
      @standing_image
    end
  end

  def add_gravity
    @vy += GRAVITY
  end
  
  def move_vertically
    if @vy > 0
      move_up
    elsif @vy < 0
      move_down
    end
  end
  
  def move_up
    @vy.to_i.times do
      if can_move?(0, 1) 
        @y += 1 
      else 
        @vy = 0
        break
      end
    end
  end
  
  def move_down
    (-@vy).to_i.times do
      if can_move?(0, -1) 
        @y -= 1 
      else 
        @vy = 0
        break
      end
    end
  end
  
  def top_can_move?(d_x, d_y)
    map_open?(@x + d_x, @y + d_y)
  end
  
  def bottom_can_move?(d_x, d_y)
    map_open?(@x + d_x, @y + d_y - HEIGHT)
  end
  
  def map_open?(x, y)
    !@map.solid?(x, y)
  end
  
  def walk_image
    (milliseconds / 175 % 2 == 0) ? @walk_image_1 : @walk_image_2
  end
  
  def can_collect?(x, y)
    (x - @x).abs < REACH && (y - @y).abs < REACH
  end
  
end