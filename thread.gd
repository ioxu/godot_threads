class_name ThreadContainer
# https://godotengine.org/qa/33120/how-do-thread-and-wait_to_finish-work

var time_start = 0
var data = {}
#var thread = Thread.new()
var thread = null

#var psa = PoolStringArray()

# warning-ignore:unused_signal
signal send_log
# warning-ignore:unused_signal
signal begin
# warning-ignore:unused_signal
signal thread_begin
signal end

var killed = false

func set_data(userdata):
	for k in userdata.keys():
		self.data[k] = userdata[k]

func begin(userdata={}):
	emit_signal("begin",self)
	thread = Thread.new()
	self.set_data(userdata)
	thread.start(self, "_thread_function", self.data, thread.PRIORITY_LOW )


# do the work
# The argument is the userdata passed from begin().
func _thread_function(userdata):
	time_start = OS.get_unix_time()

	call_deferred("emit_signal", "thread_begin", self)

	# do work
	var x = 0
	var i = 0 

#	# simulate RAM load
#	var d = pow(2,30)/8/2 # 512Mb?
#	var sstart = OS.get_ticks_msec()
#	psa.resize(d)
#	print("resize time msec: %s"%[OS.get_ticks_msec() - sstart])
	
	# simulate CPU load
	while i < userdata["depth"] * userdata["work_scale"] and not self.killed:
			x += 0.000001
			i += 1

	# finish on completion
	call_deferred("end")
	userdata["depth"] = userdata["depth"] * userdata["work_scale"]
	userdata["result"] = x
	if self.killed:
		userdata["completed_status"] = "killed"
	else:
		userdata["completed_status"] = "complete"
	return userdata

func end():
#	psa = null
	var result = thread.wait_to_finish() #result = userdata from _thread_function(userdata)
	var elapsed = OS.get_unix_time() - time_start
	#emit_signal("end", self, elapsed, result)
	thread = null
	call_deferred("emit_signal", "end", self, elapsed, result)

func kill_thread():
	# in a container of threads
	# var t = thread_node.new()
	# self.connect("kill_thread", t, "kill_thread", [], CONNECT_DEFERRED)
	# emit_signal("kill_thread")
	# to send kill signal
	self.killed = true

