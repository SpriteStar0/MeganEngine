extends Actor

var facing_left = false
var is_attacking = false

#vvvvv Changable Variables vvvvv
var can_fire = true
var rate_of_fire = 0.1



#vvvv UPDATE Code vvvvv
func _physics_process(_delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("Jump") and _velocity.y < 0.0
	var direction: = get_direction()

	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted) 
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)


#vvvvvv TestProjectile Code vvvvvv
const testprojectile = preload("res://Projectile.tscn")


func _process(_delta):
		SkillLoop()
		change_animation()

func SkillLoop():
	if Input.is_action_pressed("Shoot") and can_fire == true:
		movement_state = MovementState.SHOOT
		can_fire = false
		var testprojectile_instance = testprojectile.instance()
		testprojectile_instance.position = $BulletSpawnR.global_position
		if facing_left:
			testprojectile_instance.direction = -1
			testprojectile_instance.position = $BulletSpawnL.global_position
		get_parent().add_child(testprojectile_instance)
		yield(get_tree().create_timer(rate_of_fire), "timeout")
		can_fire = true



func fire_lock(fire):
	can_fire = fire

#vvvvv Movement Code vvvvv
func get_direction() -> Vector2:
	movement_state = MovementState.IDLE
	var direction = Vector2(
			Input.get_action_strength("Move_right") - Input.get_action_strength("Move_left"),
			-1.0 if Input.is_action_just_pressed("Jump") and is_on_floor() else 1.0
		)
	if Input.is_action_pressed("Move_left"):
		facing_left = true
		direction.x = -1
		movement_state = MovementState.RUN
	if Input.is_action_pressed("Move_right"):
		facing_left = false
		direction.x = 1
		movement_state = MovementState.RUN
	return direction




var entity_name = "Claire"
enum MovementState {IDLE, RUN, JUMP, SHOOT}
enum WeaponType {DEFAULT, GUN, SWORD}
var movement_names =  ["Idle", "Run", "Jump", "Shoot"]
var weapon_names = ["Default"]
var movement_state = MovementState.IDLE
var weapon_type = WeaponType.DEFAULT

func change_animation(animation_name = null) :
	var animation_player_node = get_node("/root/Test Level Temp/TileMap/Player/AnimationPlayer") # <<<Really Important
	var movement_name = movement_names [movement_state]
	var attack_name = "Shoot" if is_attacking else ""
	var weapon_name = weapon_names[weapon_type]
	var direction_name = "L" if facing_left else "R"
	var all_names = [
		entity_name,
		movement_name,
		attack_name,
		weapon_name,
		direction_name
	]
	
	var current_animation_name = animation_player_node.current_animation
	var next_animation_name = animation_name if animation_name else "%s%s%s%s_%s" % all_names
	if animation_player_node.has_animation(next_animation_name) :
		if current_animation_name == next_animation_name and animation_player_node.is_playing():
			pass
		else:
			print("Animation changed: %s" % next_animation_name)
			animation_player_node.play(next_animation_name)
			animation_player_node.advance(0)
			if current_animation_name:
				var start_time = animation_player_node.current_animation_position
				animation_player_node.seek(round(min(start_time, animation_player_node.current_animation_length)))
	else:
		print("Missing animation! %s" % next_animation_name)

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		out.y = speed.y *  direction.y
	if is_jump_interrupted: 
		out.y = 0.0
	return out


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "ClaireShootDefault_R" or anim_name == "ClaireShootDefault_L":
		can_fire = true
		print("animation ends")
