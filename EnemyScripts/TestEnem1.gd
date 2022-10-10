extends RigidBody2D

var velocity = Vector2() 

func _ready():
	pass # Replace with function body.

func _process(delta):
	velocity.y += 20

func take_damage(amount: int) -> void:
	print("Taking Damage" , amount)


#Enemy Code - Tell if the hurtbox has a stealable weapon or not. 
#Have it so the player can pull this value from the enemy code and use the 
#shot type that is associated with it. 
