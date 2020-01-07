extends Node2D

var delta_a = 0.0

func _ready():
	pass

func _process(delta):
	delta_a += delta * 500
	update()

func _draw():
	draw_circle_arc_poly( Vector2(0.0, 0.0), 20, delta_a, delta_a + 75, Color(1,1,1, 0.15) )


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
    var nb_points = 6
    var points_arc = PoolVector2Array()
    points_arc.push_back(center)
    var colors = PoolColorArray([color])

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
    draw_polygon(points_arc, colors)