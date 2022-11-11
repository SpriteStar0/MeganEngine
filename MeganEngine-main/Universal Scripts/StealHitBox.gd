class_name StealHitBox
extends Area2D

var varhitbox

export var damage := 5

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")

func _init() -> void:
	collision_layer = 0
	collision_mask = 16

func _on_area_entered(hitbox):
	print("PHitbox " + str(hitbox))
	varhitbox = hitbox #since Hitbox is Native to this function we have to make another varible if we want to access it from another script.
	if hitbox != null:
		owner.weapon_detection() #Calls the funtion Weapon_detection in the ownerscript. if there is another area2d touching this area2d
		return
