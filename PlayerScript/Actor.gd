# This is the base class which you should use as a base for objects
# that need to be affected by gravity or the player.

extends KinematicBody2D
class_name Actor

# This determines which direction is UP.
const FLOOR_NORMAL = Vector2.UP

# This should be self-explanatory.
export var speed = Vector2(275.0, 750.0)
export var gravity = 1700.0
export var is_affected_by_gravity = true

# We're defaulting the velocity of all Actors to 0, 0 at first.
var velocity = Vector2.ZERO

# Since we are using _process, we are saying that we do NOT need to use the
# full-blown physics system for this. _process is called every frame and
# delta represents the amount of time that passes between the last frame and
# this frame.
func _process(delta):
	# If the item is affected by gravity, apply gravitational force to the
	# object.
	if is_affected_by_gravity:
		velocity.y += gravity * delta
	# Use the new velocity components in the move_and_slide calculation and
	# assign the result of that function to velocity.
	velocity = move_and_slide(velocity, FLOOR_NORMAL, false, 4, 0.785398, false)
