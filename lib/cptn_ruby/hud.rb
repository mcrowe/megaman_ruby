class Hud
	include TextHelper

	def draw(health)
		write("Health: #{health}", 10, 10)
	end

end