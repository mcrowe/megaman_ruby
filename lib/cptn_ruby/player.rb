class Player < AnimatedObject
  include AssetsHelper
  
  HEIGHT = 30
  WIDTH = 15
  JUMP_SPEED = -20
  WALL_JUMP_SPEED = -16
  REACH = 20
  SPEED = 5
  FIREBALL_COOLDOWN = 300

  attr_reader :x, :y, :score, :health

  def initialize(x, y, map)
    @x, @y = x, y
    @map = map
    
    @direction = :left
    @stepping = false
    @vy = 0

    @hurt_sound = Sound.new('44429__thecheeseman__hurt2.wav', 300)
    @jump_sound = Sound.new('boink.wav')

    @walking_images = (0..10).map do |i|
      Gosu::Image.new($window, image_path("Xdefault_run0#{'%02d' % i}.gif"), false)
    end
    
    @standing_images = (1..3).map do |i|
      Gosu::Image.new($window, image_path("Xdefault_breathe00#{i}.gif"), true)
    end
    
    @jumping_image = @walking_images[3]
    
    @current_image = standing_image
    
    @health = 100
    
    @last_fireball_time = 0
    
    super()
  end
  
  def damage(amount)
    @health -= amount
    @hurt_sound.play
  end

  def draw
    direction = @direction == :left ? -1 : 1
    @current_image.draw_rot(@x, @y - HEIGHT - 4, ZOrder::CptnRuby, 0, 0.5, 0, direction)
  end
  
  def update(map, player)
    update_image
    add_gravity
    move_vertically
    @stepping = false  
  end

  def jump
    if !can_move_down?
      jump!(JUMP_SPEED)
    elsif !can_move_left? || !can_move_right?
      jump!(WALL_JUMP_SPEED)
    end
  end
  
  def step_right
    @direction = :right
    @stepping = true
    SPEED.to_i.times do
      break unless can_move_right?
      @x += 1
    end
  end
  
  def step_left
    @direction = :left
    @stepping = true
    SPEED.to_i.times do
      break unless can_move_left?
      @x -= 1
    end
  end
  
  def collect_gems
    old_gem_count = @map.gems.size
  
    @map.gems.reject! { |g| can_collect?(g.x, g.y) }
    
    old_gem_count - @map.gems.size
  end
  
  def dead?
    @y > @map.height_in_pixels + 2000 || @health <= 0
  end
  
  def throw_fireball
    unless milliseconds - @last_fireball_time < FIREBALL_COOLDOWN
      Fireball.new(@x, @y - 30, @direction)
      @last_fireball_time = milliseconds
    end
  end
  
  private
    
  def jump!(speed)
    @vy = speed
    @jump_sound.play
  end  
  
  def update_image
    @current_image = if @vy < 0
      @jumping_image
    elsif @stepping
      walk_image
    else
      standing_image
    end
  end

  def add_gravity
    @vy += Game::GRAVITY
  end
  
  def move_vertically
    if @vy < 0
      move_up
    elsif @vy > 0
      move_down
    end
  end
  
  def move_up
    (-@vy).to_i.times do
      if can_move_up?
        @y -= 1 
      else 
        @vy = 0
        break
      end
    end
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
    @walking_images[milliseconds / 100 % 8]
  end
  
  def standing_image
    
    c = milliseconds / 175 % 12
    
    if c == 0 || c == 2
      @standing_images[1]
    elsif c == 1
     @standing_images[2]
    else
     @standing_images[0]
   end
  end
  
  def can_collect?(x, y)
    (x - @x).abs < REACH && (y - @y).abs < REACH
  end
  
end