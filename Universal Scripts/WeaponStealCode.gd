extends Node

#Objective 1 - Have a list of statements that will be linked to
#an enemy for a hitbox to detect.
#func weapon_steal_value():
	#
var weapon_steal_value = 0



func enemy_weapon_value(weapon_s_value):
	match weapon_s_value:
		1:
			print("Weapon Type 1- Rifle")
		2:
			print("2, We havent gotten here yet")
		3:
			print("3, We havent gotten here yet")
		4:
			print("4,We havent gotten here yet")
	
#1 -  Rifle / RIF
#2 - Air Fist / AIR
#3 - Minibomb / MNB
#4 - Blade / BLA

#For now, only have 4 weapons that can be stolen


#Objective 2 - Have a collection of different attacks for Claire
#to use once the weapon is stolen off of an enemy. 


