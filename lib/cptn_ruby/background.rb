class Background
	include AssetsHelper

	def initialize
		@image = Image.new($window, image_path('space.png'), true)
	end

	def draw
		@image.draw(0, 0, ZOrder::Background)
	end  

end