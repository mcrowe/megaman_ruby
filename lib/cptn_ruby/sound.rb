class Sound
	include AssetsHelper

	def initialize(filename)
    	@sound = Gosu::Sample.new($window, sound_path(filename))
	end

	def play
		@sound.play
	end

end