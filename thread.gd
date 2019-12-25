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
#var time_now = 0

var thread = Thread.new()
var args ={}

signal send_log
signal begin
signal thread_begin
signal end

func begin(arg):
	emit_signal("begin",self)
	thread.start(self, "_thread_function", arg)

# Run here and exit.
# The argument is the userdata passed from begin().
# If no argument was passed, this one still needs to
# be here and it will be null.
func _thread_function(userdata):
	time_start = OS.get_unix_time()

	var depth = randf()*3+1
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


