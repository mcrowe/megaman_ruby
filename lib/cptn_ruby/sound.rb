class Sound
	include AssetsHelper

	def initialize(filename, cooldown_time = 0)
    @sound = Gosu::Sample.new($window, sound_path(filename))
    @last_played = 0
    @cooldown_time = cooldown_time
	end

	def play
		unless milliseconds - @last_played < @cooldown_time
		  @sound.play
		  @last_played = milliseconds
	  end 
		
	end

end