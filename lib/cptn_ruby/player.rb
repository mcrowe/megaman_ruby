class Player
  GRAVITY = 1.0
  HEIGHT = 45
  WIDTH = 25
  JUMP_SPEED = -30
  REACH = 50

  attr_reader :x, :y, :score

  def initialize(window, x, y)
    @x, @y = x, y
    @dir = :left
    @vy = 0
    @score = 0
    @map = window.map
    @beep = Gosu::Sample.new(window, "media/Beep.wav")
    @jump_sound = Gosu::Sample.new(window, "media/boink.wav")
    @standing, @walk1, @walk2, @jump = *Image.load_tiles(window, "media/CptnRuby.png", 50, 50, false)
    @current_image = @standing    
  end
  
  def draw
    direction = @dir == :left ? -1 : 1
    @current_image.draw(@x + direction * WIDTH, @y - HEIGHT - 4, ZOrder::CptnRuby, - direction * 1.0, 1.0)
  end
  
  def update(move_x)
    update_image(move_x)
    move_horizontally(move_x)
    add_gravity
    move_vertically
  end
  
  def jump
    unless can_move?(0, 1)
      @vy = JUMP_SPEED
      @jump_sound.play
    end
  end
  
  def collect_gems(gems)
    gems.reject! do |g|
      if can_collect?(g.x, g.y)
        increment_score
        true
      else
        false
      end
    end
  end
  
  private
  
  def increment_score
    @score += 1
    @beep.play
  end
  
  def can_move?(d_x, d_y)
    top_can_move?(d_x, d_y) && bottom_can_move?(d_x, d_y)
  end
  
  def update_image(move_x)
    @current_image = if @vy < 0
      @jump
    elsif move_x == 0
      @standing
    else
      walk_image

    end
  end
  
  def move_horizontally(move_x)
    if move_x > 0
      @dir = :right
      move_right(move_x)
    elsif move_x < 0
      @dir = :left
      move_left(-move_x)
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
  
  def move_right(distance)
    distance.to_i.times do
      break unless can_move?(1, 0)
      @x += 1
    end
  end
  
  def move_left(distance)
    distance.to_i.times do
      break unless can_move?(-1, 0)
      @x -= 1
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
    (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
  end
  
  def can_collect?(x, y)
    (x - @x).abs < REACH && (y - @y).abs < REACH
  end
  
end