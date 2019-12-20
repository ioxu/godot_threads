extends Node2D

########################################################################
# https://godotengine.org/qa/33120/how-do-thread-and-wait_to_finish-work
# u/Andrea
#var thread=Thread.new()
#
#func starting_function()
# thread.start(self, "thread_function", any_value)
#
#func thread_function(value):
# var r=do_your_stuff()
# call_deferred("ending_function")
# return r  #this value will be passed to ending_function
#
#func ending_function():
# var result=thread.wait_to_finish()  #result=r
# do_stuff_with_result()
########################################################################


var time_start = 0
var time_now = 0
var thread = Thread.new()
var args ={}

signal send_log

func begin(arg):
	emit_signal("send_log","thread.begin(%s)"%[arg])
	thread.start(self, "_thread_function", arg)

# Run here and exit.
# The argument is the userdata passed from begin().
# If no argument was passed, this one still needs to
# be here and it will be null.
func _thread_function(userdata):
	time_start = OS.get_unix_time()
	var x = 1.1
	var depth = randf()*3+1

	# --------------------------------------------------------------------
	# How to send information out of the thread before it has completed ??
	# Sending signals seems to be non-thread safe.
	# following code eventually causes a crash.
#	var logstr = ""
#	logstr += "-> start work %s \"%s\"\n"% [userdata["n"],userdata["name"]]
#	logstr += "  thread: %s\n"%[thread]
#	logstr += "  depth: %s %s\n"%[userdata["n"],depth]
#	emit_signal("send_log", logstr)
	# --------------------------------------------------------------------
	
	# do work
	var i = 0 
	while i < 1000000 * depth:
		x *= x
		i += 1
	args = userdata
	call_deferred("end")

	return x

func end():
	var result = thread.wait_to_finish() #result =x from _thread_function(userdata)

	# timing
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]

	# log
	var logstr = ""
	logstr += "end  %s %s : %s\n"%[args["n"],thread, str_elapsed]
	logstr += "  result: %s\n"%result
	logstr += "  %s.queue_free()"%[thread]
	emit_signal("send_log", logstr)
	
	# free
	self.queue_free()

