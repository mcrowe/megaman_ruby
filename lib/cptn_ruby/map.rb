class Map
  include AssetsHelper
  
  module Tiles
    Grass = 0
    Earth = 1
  end

  TILE_SIZE = 50
  
  attr_reader :width, :height, :gems
  
  def initialize(filename)
    # Load 60x60 tiles, 5px overlap in all four directions.
    @tileset = Image.load_tiles($window, image_path('tileset.png'), 60, 60, true)

    gem_img = Image.new($window, image_path('gem.png'), false)
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
          @gems.push(CollectibleGem.new(gem_img, TILE_SIZE*x + TILE_SIZE/2, TILE_SIZE*y + TILE_SIZE/2))
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
          @tileset[tile].draw(TILE_SIZE*x - 5, TILE_SIZE*y - 5, ZOrder::Tiles)
        end
      end
    end
    @gems.each { |c| c.draw }
  end
  
  # Solid at a given pixel position?
  def solid?(x, y)
    y < 0 || tile_at(x, y)
  end
  
  def no_more_gems?
    @gems.empty?
  end
  
  def add_block(x, y)
    set_tile_at(x, y, Tiles::Earth)
  end
  
  def remove_block(x, y)
    set_tile_at(x, y, nil)
  end
  
  def width_in_pixels
    width * TILE_SIZE
  end
  
  def height_in_pixels
    height * TILE_SIZE
  end
  
  def tile_at(x, y)
    @tiles[x / TILE_SIZE][y / TILE_SIZE]
  end
  
  def set_tile_at(x, y, value)
    @tiles[x / TILE_SIZE][y / TILE_SIZE] = value
  end
  
end