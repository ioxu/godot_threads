extends TextureRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

var iwidth = 50
var iheight = 50

var image = Image.new()
var image_texture = ImageTexture.new()

func _ready():
	image.create(iwidth, iheight, false, Image.FORMAT_RGBF)

	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 6
	noise.lacunarity = 1.5
	noise.period = 20.0
	noise.persistence = 0.8
	
	var noise_scale = 1.5 
	var noise_offset = Vector3(10,-5,0)
	var f = 0.0
	image.lock()
	for x in range(iwidth):
		for y in range(iheight):
			f = noise.get_noise_2d(x*noise_scale+noise_offset.x,y*noise_scale+noise_offset.y)
			f = (f+1)/2 * 0.25
			image.set_pixel(x , y , Color(f,f,f) )
	image.unlock()
	
	image_texture.create(iwidth, iheight, Image.FORMAT_RGBF, 0)
	image_texture.set_data(image)
	
	self.texture = image_texture

func set_nth_pixel( n, colour ):
	#var start_time = OS.get_ticks_usec()
	image.lock()
	image.set_pixel( fmod(n, iwidth),  fmod(floor(n/iwidth), iheight), colour )
	image.unlock()

	image_texture.set_data(image)
	self.texture = image_texture
	#print("thread_pixel_display.set_nth_pixel() time: ", OS.get_ticks_usec() - start_time)
	
