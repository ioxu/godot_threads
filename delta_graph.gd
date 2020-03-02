extends TextureRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var image = Image.new()
var clear_image = Image.new()
var full_image = Image.new()
var image_texture = ImageTexture.new()

var time_marker = 0.65
var timer = 0.0

var COLOR_CLEAR = Color(0, 0, 0, 0)
var COLOR_FULL = Color(0.12616, 0.609375, 0.264221) * 0.75
var COLOR_FULL_INC = Color(0.12616, 0.609375, 0.264221) * 4.0
var COLOR_EXCEED = Color(1, 0.304688, 0.51328)

func _ready():
	image.create(self.rect_size[0], self.rect_size[1], false, Image.FORMAT_RGBA8)
	image.fill(COLOR_CLEAR)
	clear_image.create(1, self.rect_size[1], false, Image.FORMAT_RGBA8)
	clear_image.fill(COLOR_CLEAR)
	full_image.create(1, self.rect_size[1], false, Image.FORMAT_RGBA8)
	full_image.fill(COLOR_FULL)
	image_texture.create(self.rect_size[0], self.rect_size[1], Image.FORMAT_RGBA8, 0)
	image_texture.set_data(image)
	self.texture = image_texture

func _process(delta):
	timer += delta
	# blit (shift graph over)
	self.image.blit_rect(self.image, Rect2(0, 0, self.rect_size[0]+1, self.rect_size[1]), Vector2(-1,0))

	# clear line (blit a clear column))
	self.image.blit_rect(self.clear_image, Rect2(0, 0, 1, self.rect_size[1]), Vector2(self.rect_size[0]-1, 0))
	
	# draw plot
	var kdt = delta / 0.016 * 0.25 * self.rect_size[1]
	if delta > 0.0165:
		self.full_image.fill(COLOR_EXCEED)
	else:
		if timer > time_marker:
			self.full_image.fill(COLOR_FULL_INC)
			timer = 0.0
		else:
			self.full_image.fill(COLOR_FULL)
	self.image.blit_rect(self.full_image, Rect2(0, 0, 1, self.rect_size[1]), Vector2(self.rect_size[0]-1, max(0,self.rect_size[1] - 1 - kdt ) ) )
	
	self.image_texture.set_data(self.image)
	self.texture = self.image_texture
	
