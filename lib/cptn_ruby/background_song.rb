class BackgroundSong
	include AssetsHelper

	def initialize
		@song_files = read_song_files
		shuffle
	end

	def toggle_play
    if @song.playing?
      pause
    else
      play
    end
  end

  def play
  	@song.play(true)
  end

  def pause
  	@song.pause
  end
  
  def shuffle
    @song = Gosu::Song.new($window, @song_files.sample)
    play
  end

  private

  def read_song_files
		Dir[sound_path + 'background_songs/*']
  end

end