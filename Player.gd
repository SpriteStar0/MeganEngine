extends Actor

var facing_left = false
var is_attacking = false

#vvvvv Changable Variables vvvvv
var can_fire = true
var rate_of_fire = 0.25

enum MovementState {IDLE, RUN, JUMP, DASH, WALL_SLIDE, HOVER}
enum WeaponType {DEFAULT, SKILL}
enum SkillType {SKILL_1, SKILL_2, SKILL_3}

var entity_name = "Claire"
var movement_names =  ["Idle", "Run", "Jump", "Dash", "Wallslide", "Hover"]
var weapon_names = ["Default", "Skill"]
var skill_names = ["Unga", "Bunga", "E"]
var movement_state = MovementState.IDLE
var weapon_type = WeaponType.DEFAULT
var skill_type = null

#vvvv UPDATE Code vvvvv
func _physics_process(_delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("Jump") and _velocity.y < 0.0
	var direction: = get_direction()

	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted) 
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)


#vvvvvv TestProjectile Code vvvvvv
const test_projectile = preload("res://Projectile.tscn")

func _process(_delta):
		SkillLoop()
		change_animation()
		if Input.is_action_just_pressed("Quit"):
			get_tree().quit()

func SkillLoop():
	if Input.is_action_pressed("Shoot") and can_fire:
		can_fire = false
		is_attacking = true
		change_animation()
		can_fire = true
	else:
		is_attacking = false

func shoot_gun():
	var test_projectile_instance = test_projectile.instance()
	test_projectile_instance.position = $BulletSpawnR.global_position
	if facing_left:
		test_projectile_instance.direction = -1
		test_projectile_instance.position = $BulletSpawnL.global_position
	get_parent().add_child(test_projectile_instance)

#vvvvv Movement Code vvvvv
func get_direction() -> Vector2:
	if not Input.is_action_pressed("Shoot"):
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




func change_animation(animation_name = null) :
	var animation_player_node = get_node("/root/Test Level Temp/TileMap/Player/AnimationPlayer") # <<<Really Important
	var movement_name = movement_names [movement_state]
	var attack_name = "Attack" if is_attacking else ""
	var weapon_name = weapon_names[weapon_type]
	var skill_name = "" if skill_type == null else skill_names[skill_type]
	var direction_name = "L" if facing_left else "R"
	var all_names = [
		entity_name,
		movement_name,
		attack_name,
		weapon_name,
		skill_name,
		direction_name
	]
	
	# ClaireIdleAttackDefault_R
	# ClaireRunAttackDefault_R
	# ClaireRunDefault_R
	
	var current_animation_name = animation_player_node.current_animation
	var next_animation_name = animation_name if animation_name else "%s%s%s%s%s_%s" % all_names
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
