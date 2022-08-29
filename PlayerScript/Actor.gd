extends KinematicBody2D
class_name Actor

const FLOOR_NORMAL = Vector2.UP

export var speed = Vector2(275.0, 750.0)
export var gravity = 1700.0

var velocity = Vector2.ZERO

func _process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.785398, false)
