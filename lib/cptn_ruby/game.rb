class Game < Window
  include AssetsHelper
  include TextHelper

  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 800
  GRAVITY = 1

  attr_reader :map

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false) # true for fullscreen
    self.caption = 'Captain Ruby'
  end

  def show
    @paused = false
    @level = 0
    @score = 0

    @background = Background.new
    @hud = Hud.new
    @beep = Sound.new('beep.wav')
    @song = BackgroundSong.new

    @camera_x = @camera_y = 0
    
    @click_mode = :map
    
    load_next_level

    super
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
  
  def needs_cursor?
    true
  end
  
  private
  
  def update!
    return if paused?
    return if loading_level?
    
    if @click_mode == :map
      add_map_block if button_down?(MsLeft)
      remove_map_block if button_down?(MsRight)
    end
    
    @player.step_left if button_down?(KbLeft)
    @player.step_right if button_down?(KbRight)
        
    gems_collected = @player.collect_gems
    
    AnimatedObject.update_all(@map, @player)

    update_score(gems_collected)
    
    update_camera

    load_level if @player.dead?
    load_next_level if level_complete?
  end
  
  def draw!
    draw_paused if paused?
    
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
      @song.toggle_play
    when KbO
      @song.shuffle
    when Kb1
      @click_mode = :bad_dude
    when Kb2
      @click_mode = :map
    when KbL
      @player.throw_fireball
    when MsLeft
      if @click_mode == :bad_dude
        @bad_dudes << BadDude.new(mouse_x + @camera_x, mouse_y + @camera_y, @map)
      end
    end
  end
  
  def add_map_block
    @map.add_block(mouse_x + @camera_x, mouse_y + @camera_y)
  end
  
  def remove_map_block
    @map.remove_block(mouse_x + @camera_x, mouse_y + @camera_y)
  end
  
  def draw_world
    @background.draw
    @hud.draw(@player.health)
          
    relative_to_camera do
      AnimatedObject.draw_all
      
      @map.draw
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
    max_x = @map.width_in_pixels - SCREEN_WIDTH
    x_with_player_in_center_screen = @player.x - (SCREEN_WIDTH / 2)
    @camera_x = [ [0, x_with_player_in_center_screen].max, max_x].min
    
    max_y = @map.height_in_pixels - SCREEN_HEIGHT
    y_with_player_in_center_screen = @player.y - (SCREEN_HEIGHT / 2)
    @camera_y = [ [0, y_with_player_in_center_screen].max, max_y].min 
  end
  
  def draw_paused
    x = (SCREEN_WIDTH / 2) - 35
    y = (SCREEN_HEIGHT / 2) - 20
    
    write('PAUSED', x, y)
  end
  
  def load_next_level
    @level += 1
    load_level
  end
  
  def load_level
    @map = Map.new(asset_path("maps/map_level_#{@level}.txt"))
    @player = Player.new(400, 100, @map)
    @bad_dudes = [
      BadDude.new(800, 300, @map),
      BadDude.new(900, 300, @map)
    ]
      
    @load_level_start = milliseconds    
  end
  
  def loading_level?
    milliseconds - @load_level_start < 3_000
  end
  
  def draw_level_loading
    x = (SCREEN_WIDTH / 2) - 35
    y = (SCREEN_HEIGHT / 2) - 20
    
    write("LEVEL #{@level}", x, y)
  end
  
  def relative_to_camera
    translate(-1 * @camera_x, -1 * @camera_y) do 
      yield
    end
  end
  
  def level_complete?
    @map.no_more_gems?
  end
  
  def update_score(number_of_gems_collected)
    @score += number_of_gems_collected
    @beep.play if number_of_gems_collected > 0
  end

end