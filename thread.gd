extends Node
# https://godotengine.org/qa/33120/how-do-thread-and-wait_to_finish-work

var time_start = 0

var data = {}

var thread = Thread.new()

# warning-ignore:unused_signal
signal send_log
# warning-ignore:unused_signal
signal begin
# warning-ignore:unused_signal
signal thread_begin
signal end

func set_data(userdata):
	for k in userdata.keys():
		self.data[k] = userdata[k]

func begin(userdata={}):
	#emit_signal("begin",self)
	self.set_data(userdata)
	thread.start(self, "_thread_function", self.data, thread.PRIORITY_LOW )

# do the work
# The argument is the userdata passed from begin().
func _thread_function(userdata):
	time_start = OS.get_unix_time()

	var depth = int(10000000 * randf()*2 * userdata["work_scale"])
	call_deferred("emit_signal", "thread_begin", self)

	# do work
	var x = 0
	var i = 0 
	while i < depth:
		x += 0.000001
		i += 1
	call_deferred("end")

	userdata["depth"] = depth
	userdata["result"] = x
	return userdata

func end():
	var result = thread.wait_to_finish() #result = userdata from _thread_function(userdata)
	var elapsed = OS.get_unix_time() - time_start
	emit_signal("end", self, elapsed, result)


