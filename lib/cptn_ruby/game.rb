class Game < Window

  attr_reader :map

  def initialize
    super(960, 560, false)
    self.caption = "Cptn. Ruby"
    @sky = Image.new(self, "media/Space.png", true)
    @map = Map.new(self, "media/level1_map.txt")
    @cptn = Player.new(self, 400, 100)
    # The scrolling position is stored as top left corner of the screen.
    @camera_x = @camera_y = 0
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @background_music = Gosu::Sample.new(self, "media/8-bit-loop.mp3")
    # @background_music.play(1, 1, true)
    @loading = false
    @level = 1
    @paused = false
  end   
  
  def update
    return if paused?
    
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
      @cptn = Player.new(self, 400, 100)
      @loading = false
    end
  
  rescue StandardError => e
    puts e
    pause
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
    
  rescue StandardError => e
    puts e
    pause
  end
  
  def button_down(id)
    case id
    when KbUp     then @cptn.jump
    when KbEscape then close
    when KbSpace  then toggle_paused
    end
    
  rescue StandardError => e
    puts e
    pause
  end
  
  private
  
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
  
  
end