# Godot Threads
Experimentation with mutithreading in the Godot game engine.

Spam the 'do work' button to load up on threads.

This is designed to be an almost minimal working example of watching threads do work that take longer than a game tick.

A dictionary of user data is passed to the thread as parameterisation, and the same dictionaty is returned with the result of the work done in the key "result."

The threads send signals to the mainloop on beginning and ending to trigger the logger.

https://godotengine.org/

