extends Node2D

onready var log_output_rich = get_node("Control/log_output_rich")
export var MAX_LOG_LINES = 80
export var VISIBLE_LOG_LINES = 40

onready var thread = preload("res://thread.tscn")

var n_processors = OS.get_processor_count()

onready var n_processors_label = get_node("Control/threads_container/n_processors_label")
onready var n_max_processors_spinbox = get_node("Control/threads_container/max_processors_spinbox")
onready var n_queued_threads_label = get_node("Control/threads_container/n_queued_threads_label")
onready var n_active_threads_label = get_node("Control/threads_container/n_active_threads_label")
onready var fps_label = get_node("Control/fps")
onready var work_load_scale_spinbox= get_node("Control/threads_container/work_load_scale_spinbox")

var threadn = 0

var thread_list = []
var thread_queued_list = []
var thread_active_list = []


func _ready():
	n_processors_label.text = str(n_processors)
	n_active_threads_label.text = str(0)
	n_max_processors_spinbox.value = n_processors - 1
	
	n_queued_threads_label.text = "0"
	n_active_threads_label.text = "0"
	reset_log()


func _process(delta):
	fps_label.text = "%s fps"%[str(Engine.get_frames_per_second())]
	#if delta !=0:
	#	fps_label.text = "%0.1f fps"%[1.0/delta]


# initiate thread jobs
func _on_do_work_button_button_up():
	for i in range(100): 

		var t = thread.instance()
		thread_list.append(t)
		thread_queued_list.append(t)

		t.connect("send_log", self, "_on_log")
		t.connect("begin", self, "_on_thread_begin")
		t.connect("thread_begin", self, "_on_thread_thread_begin")
		t.connect("end", self, "_on_thread_end")

		t.set_data({"work_scale":work_load_scale_spinbox.get_value(),
				"result": null,
				"n":threadn,
				"name":"thread_%s"%[threadn] })

		threadn += 1

	self.check_for_spare_slots()
	self.update_thread_display()


# move threads into spare <n_procs-max_procs> slots
# and call begin
func check_for_spare_slots():
	# find how many to move to spare slots
	var move = min( thread_queued_list.size(), n_max_processors_spinbox.value - thread_active_list.size() )
	if move != 0:
		for i in range(move):
			var t = thread_queued_list.pop_front()
			t.begin()
			thread_active_list.append(t)
	elif thread_active_list.size() == 0:
		self._on_log("complete - no more active threads!")


# free the queued thread jobs
func _on_stop_work_button_button_up():
	print("STOP WORK")
	for t in thread_queued_list:
		# this works even better with the thread queue
		# because the threads haven't been started yet
		# and they clean up much sooner
		t.queue_free()
	thread_queued_list.clear()
	# find a way to pass a kill message to active threads ..
	self.update_thread_display()


# thread state signals
func _on_thread_begin(thread):
#	_on_log("init %s"%[thread])
#	self.update_thread_display()
	pass


func _on_thread_thread_begin(thread):
	_on_log("begin %s"%[thread])
	self.update_thread_display()


func _on_thread_end(thread, elapsed, result):
	_on_log("end %s (%02d:%02d)"%[thread, elapsed / 60, elapsed % 60])
	_on_log( "    %s"%[result] )
	thread_list.erase(thread)
	thread_active_list.erase(thread)
	self.check_for_spare_slots()
	self.update_thread_display()


func update_thread_display():
	n_queued_threads_label.text = str(thread_queued_list.size())
	n_active_threads_label.text = str(thread_active_list.size())


func _on_log(data):
	# this bbcode formatting is cruising for a bruising --
#	var c = Color(0.321569, 0.721569, 0.960784)
	var data_split = str(data).split(" ")
	if data_split[0] == "init":
		log_output_rich.append_bbcode("[code][color=#f8d469]"+data_split[0]+"[/color] "+ array_join(data_split, 1, " ")+"[/code]")
		log_output_rich.newline()
	elif data_split[0] == "begin":
		log_output_rich.append_bbcode("[code][color=#5aff48]"+data_split[0]+"[/color] "+ array_join(data_split, 1, " ")+"[/code]")
		log_output_rich.newline()
	elif data_split[0] == "end":
		log_output_rich.append_bbcode("[code][color=#ff4b9f]"+data_split[0]+"[/color] "+ array_join(data_split, 1, " ")+"[/code]")
		log_output_rich.newline()
	elif data_split[0] == "complete":
		log_output_rich.append_bbcode("[code][color=#52b8f5]----------------------------------[/color]"+"[/code]")
		log_output_rich.newline()
		log_output_rich.append_bbcode("[code][color=#52b8f5]"+data_split[0]+"[/color] "+ array_join(data_split, 1, " ")+"[/code]")
		log_output_rich.newline()
		log_output_rich.append_bbcode("[code][color=#52b8f5]----------------------------------[/color]"+"[/code]")
		log_output_rich.newline()
	elif data_split[0] == "log":
		log_output_rich.append_bbcode("[code][color=#feff7d]"+data_split[0]+"[/color] "+ array_join(data_split, 1, " ")+"[/code]")
		log_output_rich.newline()
	else:
		log_output_rich.append_bbcode("[code]"+str(data)+"[/code]")
		log_output_rich.newline()
	# ----------------------------------------------------

	self.request_log_cull()


func request_log_cull():
	if log_output_rich.get_line_count() > MAX_LOG_LINES:
		for i in range( MAX_LOG_LINES - VISIBLE_LOG_LINES ):
			log_output_rich.remove_line(0)
		self._on_log("log  cleared %s lines"%[ MAX_LOG_LINES - VISIBLE_LOG_LINES])


func _on_clear_log_button_button_up():
	reset_log()


func reset_log():
	log_output_rich.bbcode_text = ""
	
	_on_log( "log started %s"%[get_pretty_time()] )
	_on_log( "log processors %s"%[OS.get_processor_count()] )
	_on_log( "log ------------------------------------------------")
	

func _on_max_processors_spinbox_value_changed(value):
	_on_log("max processors changed to %s"%[value])


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






