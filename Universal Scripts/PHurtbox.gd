class_name PHurtbox
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 16
	
func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	

func _on_area_entered(hitbox: PHitbox) -> void:
	print("Hurtbox")
	if hitbox == null:
		
		return
	
		
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
		#owner.queue_free()
		hitbox.owner.queue_free()
