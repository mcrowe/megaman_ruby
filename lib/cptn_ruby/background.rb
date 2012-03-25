class Background
	include AssetsHelper

	def initialize
		@image = Image.new($window, image_path('space4.png'), true)
	end

	def draw
    # @image.draw(0, 0, ZOrder::Background, 1, 1)
	end  

end