class_name PHitbox
extends Area2D

export var damage := 5

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")

func _init() -> void:
	collision_layer = 0
	collision_mask = 16

func _on_area_entered(hitbox):
	print_debug("damage") #Put the code to dammage the emeny here.
	if hitbox == null:
		return
