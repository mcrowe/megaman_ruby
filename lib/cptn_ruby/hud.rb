class Hud
	include TextHelper

	def draw(score)
		write("Score: #{score}", 10, 10)
	end

end