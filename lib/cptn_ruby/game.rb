class Game < Window

  SCREEN_WIDTH = 960
  SCREEN_HEIGHT = 560

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
    when KbUp     then @player.jump
    when KbEscape then close
    when KbSpace  then toggle_paused
    when KbR      then load_level
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
    @camera_x = [[@player.x - 480, 0].max, @map.width * 50 - 960].min
    @camera_y = [[@player.y - 280, 0].max, @map.height * 50 - 560].min 
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
    @font.draw("Loading Level #{@level} ...", 250, 220, ZOrder::UI, 1.0, 1.0, 0xffffffff)
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
  
end