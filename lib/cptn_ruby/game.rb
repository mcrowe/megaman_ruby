class Game < Window

  SCREEN_WIDTH = 960
  SCREEN_HEIGHT = 560
  TILE_SIZE = 50

  attr_reader :map

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
    self.caption = 'Captain Ruby'
    
    @sky = Image.new(self, 'media/Space.png', true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @background_music = Gosu::Sample.new(self, 'media/8-bit-loop.mp3')
    # @background_music.play(1, 1, true)
    @paused = false
    @level = 0
    
    load_next_level
  end   
  
  def update
    pause_on_exception { update! }
  end

  def draw
    pause_on_exception { draw! }
  end
  
  def button_down(button)
    pause_on_exception { button_down!(button) }
  end
  
  private
  
  def update!
    return if paused?
    return if loading_level?
    
    move_x = 0
    move_x -= 5 if button_down?(KbLeft)
    move_x += 5 if button_down?(KbRight)
    @player.update(move_x)
    @player.collect_gems(@map.gems)
    
    update_camera

    if @map.gems.empty?
      load_next_level
    end
  end
  
  def draw!
    return if paused?
    
    if loading_level?
      draw_level_loading
    else
      draw_world       
    end
    
  end
  
  def button_down!(button)
    case button
    when KbUp     
      @player.jump
    when KbEscape
      close
    when KbSpace
      toggle_paused
    when KbR
      load_level
    end
  end
  
  def draw_world
    draw_sky
    draw_hud
          
    relative_to_camera do
      draw_map
      draw_player
    end
  end
  
  def pause_on_exception
    yield
  rescue StandardError => e
    puts e.message
    puts e.backtrace.first
    pause
  end
  
  def pause
    puts 'Pausing...'
    @paused = true
  end
  
  def toggle_paused
    @paused = !@paused
  end
  
  def paused?
    @paused
  end
  
  def update_camera
    max_x = map_width_in_pixels - SCREEN_WIDTH
    x_with_player_in_center_screen = @player.x - (SCREEN_WIDTH / 2)
    @camera_x = [ [0, x_with_player_in_center_screen].max, max_x].min
    
    max_y = map_height_in_pixels - SCREEN_HEIGHT
    y_with_player_in_center_screen = @player.y - (SCREEN_HEIGHT / 2)
    @camera_y = [ [0, y_with_player_in_center_screen].max, max_y].min 
  end
  
  def draw_hud
    @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
  
  def load_next_level
    @level += 1
    load_level
  end
  
  def load_level
    @map = Map.new(self, "media/level#{@level}_map.txt")
    @player = Player.new(self, 400, 100)
    @load_level_start = milliseconds    
  end
  
  def loading_level?
    milliseconds - @load_level_start < 3_000
  end
  
  def draw_level_loading
    x = (SCREEN_WIDTH / 2) - 100
    y = (SCREEN_HEIGHT / 2) - 10
    
    @font.draw("Loading Level #{@level} ...", x, y, ZOrder::UI, 1.0, 1.0, 0xffffffff)
  end
  
  def draw_sky
    @sky.draw(0, 0, ZOrder::Sky)  
  end
  
  def relative_to_camera
    translate(-@camera_x, -@camera_y) do 
      yield
    end
  end
  
  def draw_map
    @map.draw
  end
  
  def draw_player
    @player.draw
  end
  
  def map_width_in_pixels
    @map.width * TILE_SIZE
  end
  
  def map_height_in_pixels
    @map.height * TILE_SIZE
  end
  
end