extends Node2D

onready var log_output = get_node("Control/log_output")
onready var log_output_rich = get_node("Control/log_output_rich")
onready var thread = preload("res://thread.tscn")

onready var n_processors_label = get_node("Control/threads_container/n_processors_label")
onready var n_max_processors_spinbox = get_node("Control/threads_container/max_processors_spinbox")
onready var n_active_threads_label = get_node("Control/threads_container/n_active_threads_label")

var threadn = 0

func _ready():
	n_processors_label.text = str(OS.get_processor_count())
	n_active_threads_label.text = str(0)
	n_max_processors_spinbox.value = OS.get_processor_count() - 1 
	
	reset_log()

func _on_do_work_button_button_up():
	print("do_work")
	for i in range(10): 

		print("start %s"%[i])
		var t = thread.instance()
		print(t)

		t.connect("send_log", self, "_on_thread_log")
		t.begin({"n":threadn, "name":"thread_%s"%[threadn]})
		threadn += 1

func _on_thread_log(data):
	print(str(data))
	log_output.text += str(data) + "\n"

	# this bbcode formatting is cruising for a bruising --
	var data_split = str(data).split(" ")
	if data_split[0] == "start":
		#var c = Color(1, 0.294118, 0.623529)
		data =  "[color=#5aff48]"+data_split[0]+"[/color] "+ array_join(data_split, 1, " ")
	elif data_split[0] == "end":
		data =  "[color=#ff4b9f]"+data_split[0]+"[/color] "+ array_join(data_split, 1, " ")
	log_output_rich.set_bbcode( log_output_rich.get_bbcode() + "[code]" + str(data) + "[/code]\n" )
	# ----------------------------------------------------
	
	self._on_log_output_cursor_changed()

func _on_log_output_cursor_changed():
	log_output.cursor_set_line( log_output.get_line_count() )

func _on_clear_log_button_button_up():
	reset_log()

func reset_log():
	log_output.text = ""
	log_output_rich.bbcode_text = ""
	
	var s = "log started %s\n"%[get_pretty_time()]
	s += "processors %s\n"%[OS.get_processor_count()]
	s += "------------------------------------------------\n"
	_on_thread_log( s )

func _on_max_processors_spinbox_value_changed(value):
	_on_thread_log("max processors changed to %s"%[value])

# UTIL -----------------
func array_join(arr,i_start ,sep = ' '):
	var string = ''
	for index in range(i_start, arr.size()):
		string += str(arr[index])
		if index < arr.size() - 1:
			string += sep
	return string

func get_pretty_time():
	# https://godotengine.org/qa/19077/how-to-get-the-date-as-per-rfc-1123-date-format-in-game
	# u/jospic
	var time = OS.get_datetime()
	var nameweekday= ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var namemonth= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var dayofweek = time["weekday"]   # from 0 to 6 --> Sunday to Saturday
	var day = time["day"]                         #   1-31
	var month= time["month"]               #   1-12
	var year= time["year"]             
	var hour= time["hour"]                     #   0-23
	var minute= time["minute"]             #   0-59
	var second= time["second"]             #   0-59
	return "%s, %02d %s %d %02d:%02d:%02d GMT" % [nameweekday[dayofweek], day, namemonth[month-1], year, hour, minute, second]


