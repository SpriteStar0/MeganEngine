extends KinematicBody2D
class_name Actor

const FLOOR_NORMAL = Vector2.UP

export var speed = Vector2(275.0, 750.0)
export var gravity = 1700.0
export var is_affected_by_gravity = true

var velocity = Vector2.ZERO

func _process(delta):
	if is_affected_by_gravity:
		velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.785398, false)
