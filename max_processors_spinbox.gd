extends SpinBox


func _on_max_processors_spinbox_value_changed(value):
	print(self, ".changed")
	self.release_focus()
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		self.release_focus()
		