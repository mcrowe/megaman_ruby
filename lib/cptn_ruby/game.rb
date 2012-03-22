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
    @beep = Gosu::Sample.new(self, "media/Beep.wav")

    @paused = false
    @level = 0
    @score = 0

    load_next_song    
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
    
    @player.step_left if button_down?(KbLeft)
    @player.step_right if button_down?(KbRight)
    
    @player.update
    
    gems_collected = @player.collect_gems

    if gems_collected > 0
      @score += gems_collected
      @beep.play
    end
    
    update_camera

    load_next_level if level_complete?

  end
  
  def draw!
  
    if paused?
      draw_paused
    end
    
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
    when KbP
      toggle_song
    when KbO
      load_next_song  
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
    @font.draw("Score: #{@score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
  
  def draw_paused
    x = (SCREEN_WIDTH / 2) - 35
    y = (SCREEN_HEIGHT / 2) - 20
    
    @font.draw("PAUSED", x, y, ZOrder::UI, 1.0, 1.0, 0xffffffff)
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
    x = (SCREEN_WIDTH / 2) - 35
    y = (SCREEN_HEIGHT / 2) - 20
    
    @font.draw("LEVEL #{@level}", x, y, ZOrder::UI, 1.0, 1.0, 0xffffffff)
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
  
  def level_complete?
    @map.no_more_gems?
  end
  
  def toggle_song
    if @song.playing?
      @song.pause
    else
      @song.play(true)
    end
  end
  
  def load_next_song
    filename = ['8-bit-electrohouse.wav', '8-bit-loop.mp3', 'spy-game-sneeking.mp3'].sample
      
    @song = Gosu::Song.new(self, "media/#{filename}")
    toggle_song
  end
  
end