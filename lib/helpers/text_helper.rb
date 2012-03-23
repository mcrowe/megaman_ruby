module TextHelper

	def default_font
		@default_font ||= Gosu::Font.new($window, Gosu::default_font_name, 20)
	end

	def write(message, x, y, font = default_font)
		font.draw(message, x, y, ZOrder::UI, 1.0, 1.0, 0xffffffff)
	end

end