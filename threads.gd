extends Node2D

onready var log_output = get_node("Control/log_output")
onready var thread = preload("res://thread.tscn")
var threadn = 0

func _ready():
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
	self._on_log_output_cursor_changed()

func _on_log_output_cursor_changed():
	log_output.cursor_set_line( log_output.get_line_count() )

func _on_clear_log_button_button_up():
	reset_log()

func reset_log():
	log_output.text = "log started %s"%[get_pretty_time()]
	log_output.text += "\n------------------------------------------------\n"

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