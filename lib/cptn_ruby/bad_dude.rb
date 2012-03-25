class BadDude
  include AssetsHelper
  extend AssetsHelper
  GRAVITY = 1
  
  HEIGHT = 30
  WIDTH = 15
  JUMP_SPEED = -20
  WALL_JUMP_SPEED = -16
  REACH = 20
  SPEED = 3


  attr_reader :x, :y, :score



  def initialize(x, y, map)
    @x, @y = x, y
    @direction = :left
    @stepping = false
    @vy = 0
    @map = map

    
    @current_image = standing_image
  end
  
  def draw
    direction = @direction == :left ? -1 : 1
    @current_image.draw_rot(@x, @y - HEIGHT - 4, ZOrder::CptnRuby, 0, 0.5, 0, direction)
  end
  
  def can_touch?(player)
    (@x - player.x).abs < REACH && (@y - player.y).abs < REACH
  end
  
  def update(player)
    update_image
    add_gravity
    move_vertically
    
    @stepping = false
    
    # c = milliseconds / 175 % 20
    
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
  
  def growl
    BadDude.jump_sound.play
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
    @y > @map.height_in_pixels + 2000
  end
  
  private
    
  def jump!(speed)
    @vy = speed
    @jump_sound.play
  end  
  
  def update_image
    @current_image = if @vy < 0
      @@jumping_image
    elsif @stepping
      walk_image
    else
      standing_image
    end
  end

  def add_gravity
    @vy += GRAVITY
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
    BadDude.walking_images[milliseconds / 100 % 8]
  end
  
  def standing_image
    
    c = milliseconds / 175 % 12
    
    if c == 0 || c == 2
      BadDude.standing_images[1]
    elsif c == 1
     BadDude.standing_images[2]
    else
     BadDude.standing_images[0]
   end
  end
  
  def can_collect?(x, y)
    (x - @x).abs < REACH && (y - @y).abs < REACH
  end
  
  def self.jump_sound
    @@jump_sound ||= Sound.new('boink.wav')
  end

  def self.walking_images
    @@walking_images ||= (0..10).map do |i|
      Gosu::Image.new($window, image_path("Xdefaultfire_run0#{'%02d' % i}.gif"), false)
    end
  end
  
  def self.standing_images
    @@standing_images ||= (1..3).map do |i|
      Gosu::Image.new($window, image_path("Xdefault_breathe00#{i}.gif"), true)
    end
  end
  
  def self.jumping_image
    @@jumping_image ||= @@walking_images[3]
  end
  
end