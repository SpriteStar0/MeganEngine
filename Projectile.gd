extends Area2D

var projectile_speed = 800
var direction = 1

func _physics_process(delta):
	position.x += projectile_speed * direction * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
