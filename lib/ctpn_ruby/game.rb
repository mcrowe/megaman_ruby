module Tiles
  Grass = 0
  Earth = 1
end

module ZOrder
  Sky, Tiles, Gems, CptnRuby, UI = *0..4
end

class CollectibleGem
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x, @y = x, y
  end
  
  def draw
    # Draw, slowly rotating
    @image.draw_rot(@x, @y, ZOrder::Gems, 25 * Math.sin(milliseconds / 133.7))
  end
  
  def empty?
    size == 0
  end
  
end

# Player class.
class CptnRuby
  attr_reader :x, :y, :score

  def initialize(window, x, y)
    @x, @y = x, y
    @dir = :left
    @vy = 0 # Vertical velocity
    @score = 0
    @map = window.map
    @beep = Gosu::Sample.new(window, "media/Beep.wav")
    @jump_sound = Gosu::Sample.new(window, "media/boink.wav")
    # Load all animation frames
    @standing, @walk1, @walk2, @jump =
      *Image.load_tiles(window, "media/CptnRuby.png", 50, 50, false)
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @standing    
  end
  
  def draw
    # Flip vertically when facing to the left.
    if @dir == :left then
      offs_x = -25
      factor = 1.0
    else
      offs_x = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, ZOrder::CptnRuby, factor, 1.0)
  end
  
  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    not @map.solid?(@x + offs_x, @y + offs_y) and
      not @map.solid?(@x + offs_x, @y + offs_y - 45)
  end
  
  def update(move_x)
    # Select image depending on action
    if (move_x == 0)
      @cur_image = @standing
    else
      @cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end
    
    # Directional walking, horizontal movement
    if move_x > 0 then
      @dir = :right
      move_x.times { if would_fit(1, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
    end

    # Acceleration/gravity
    # By adding 1 each frame, and (ideally) adding vy to y, the player's
    # jumping curve will be the parabole we want it to be.
    @vy += 1
    # Vertical movement
    if @vy > 0 then
      @vy.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
    end
    if @vy < 0 then
      (-@vy).times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
    end
  end
  
  def try_to_jump
    if @map.solid?(@x, @y + 1) then
      @vy = -30
      @jump_sound.play
    end
  end
  
  def collect_gems(gems)
    # Same as in the tutorial game.
    gems.reject! do |c|
      if (c.x - @x).abs < 50 and (c.y - @y).abs < 50
        @score += 1
        @beep.play
        true
      else
        false
      end
    end
  end
end

# Map class holds and draws tiles and gems.
class Map
  attr_reader :width, :height, :gems
  
  def initialize(window, filename)
    # Load 60x60 tiles, 5px overlap in all four directions.
    @tileset = Image.load_tiles(window, "media/CptnRuby Tileset.png", 60, 60, true)

    gem_img = Image.new(window, "media/CptnRuby Gem.png", false)
    @gems = []

    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when '"'
          Tiles::Grass
        when '#'
          Tiles::Earth
        when 'x'
          @gems.push(CollectibleGem.new(gem_img, x * 50 + 25, y * 50 + 25))
          nil
        else
          nil
        end
      end
    end
  end
  
  def draw
    # Very primitive drawing function:
    # Draws all the tiles, some off-screen, some on-screen.
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          # Draw the tile with an offset (tile images have some overlap)
          # Scrolling is implemented here just as in the game objects.
          @tileset[tile].draw(x * 50 - 5, y * 50 - 5, ZOrder::Tiles)
        end
      end
    end
    @gems.each { |c| c.draw }
  end
  
  # Solid at a given pixel position?
  def solid?(x, y)
    y < 0 || @tiles[x / 50][y / 50]
  end
end

class Game < Window
  attr_reader :map

  def initialize
    super(960, 560, false)
    self.caption = "Cptn. Ruby"
    @sky = Image.new(self, "media/Space.png", true)
    @map = Map.new(self, "media/level1_map.txt")
    @cptn = CptnRuby.new(self, 400, 100)
    # The scrolling position is stored as top left corner of the screen.
    @camera_x = @camera_y = 0
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @background_music = Gosu::Sample.new(self, "media/8-bit-loop.mp3")
    @background_music.play(1, 1, true)
    @loading = false
    @level = 2
  end   
  
  def update
    move_x = 0
    move_x -= 5 if button_down? KbLeft
    move_x += 5 if button_down? KbRight
    @cptn.update(move_x)
    @cptn.collect_gems(@map.gems)
    # Scrolling follows player
    @camera_x = [[@cptn.x - 320, 0].max, @map.width * 50 - 640].min
    @camera_y = [[@cptn.y - 240, 0].max, @map.height * 50 - 480].min
    
    if @loading
      sleep 3
      @level += 1
      @map = Map.new(self, "media/level#{@level}_map.txt")
      @cptn = CptnRuby.new(self, 400, 100)
      @loading = false
    end
    
  end
  
  def draw
    @sky.draw(0, 0, ZOrder::Sky)      
    translate(-@camera_x, -@camera_y) do
      @map.draw
      @cptn.draw
    end
    @font.draw("Score: #{@cptn.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    
    if @map.gems.empty?
      @font.draw("Loading Level #{@level} ...", 250, 220, ZOrder::UI, 1.0, 1.0, 0xffffffff)
      @loading = true
    end
  end
  
  def button_down(id)
    if id == KbUp then @cptn.try_to_jump end
    if id == KbEscape then close end
  end
  
end