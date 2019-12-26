extends Node2D
# https://godotengine.org/qa/33120/how-do-thread-and-wait_to_finish-work

var time_start = 0

var data = {}

var thread = Thread.new()

# warning-ignore:unused_signal
signal send_log
signal begin
# warning-ignore:unused_signal
signal thread_begin
signal end

func set_data(userdata):
	for k in userdata.keys():
		self.data[k] = userdata[k]

func begin(userdata={}):
	emit_signal("begin",self)
	self.set_data(userdata)
	thread.start(self, "_thread_function", self.data )

# do the work
# The argument is the userdata passed from begin().
func _thread_function(userdata):
	time_start = OS.get_unix_time()

	var depth = randf()*2 * 0.3
	call_deferred("emit_signal", "thread_begin", self)

	# do work
	var x = 0#1.000001
	var i = 0 
	while i < 10000000 * depth:
		x += 0.000001
		i += 1
	call_deferred("end")

	userdata["result"] = x
	return userdata

func end():
	var result = thread.wait_to_finish() #result =x from _thread_function(userdata)
	var elapsed = OS.get_unix_time() - time_start
	emit_signal("end", self, elapsed, result)
	self.queue_free()


