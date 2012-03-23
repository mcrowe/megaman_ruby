module AssetsHelper

	def image_path(path = '')
	asset_path("images/#{path}")
	end

	def sound_path(path = '')
	asset_path("sounds/#{path}")
	end

	def asset_path(path = '')
	"assets/#{path}"
	end

end

