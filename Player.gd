extends Actor

#vvvvvv TestProjectile Code vvvvvv
const test_projectile = preload("res://Projectile.tscn")

var facing_left = false
var is_attacking = false
var max_number_of_jumps = 3
var number_of_jumps = max_number_of_jumps

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
func _process(delta):
	handle_special_actions(delta)
	handle_attacking()
	handle_movement()
	handle_other_input()
	change_animation()

# warning-ignore:unused_argument
#func start_jump(delta):
	

func jump(delta):
	if number_of_jumps > 0:
		movement_state = MovementState.JUMP
		velocity.y = 0
		velocity.y -= speed.y
		number_of_jumps -= 1
		
func loop_falling():
	if is_on_floor():
		movement_state = MovementState.IDLE
		change_animation()
	else:
		$AnimationPlayer.seek(0.4)

func set_can_fire(enabled):
	can_fire = enabled

func handle_attacking():
	if Input.is_action_pressed("Shoot"):
		is_attacking = true
		if can_fire:
			can_fire = false
			var attack_timer = Timer.new()
			attack_timer.one_shot = true
			attack_timer.wait_time = rate_of_fire
			attack_timer.connect("timeout", self, "set_can_fire", [true])
			add_child(attack_timer)
			attack_timer.start()
	else:
		is_attacking = false

func handle_other_input():
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
		
func handle_special_actions(delta):
	if is_on_floor():
		if movement_state == MovementState.JUMP:
			movement_state = MovementState.IDLE
		number_of_jumps = max_number_of_jumps
	if Input.is_action_just_pressed("Jump"):
		jump(delta)

func shoot_gun():
	var spawn_point = $BulletSpawnL if facing_left else $BulletSpawnR
	var test_projectile_instance = test_projectile.instance()
	test_projectile_instance.direction = -1 if facing_left else 1
	test_projectile_instance.position = spawn_point.global_position
	get_parent().add_child(test_projectile_instance)

#vvvvv Movement Code vvvvv
func handle_movement():
	var directionality = 0
	if Input.is_action_pressed("Move_left") or Input.is_action_pressed("Move_right"):
		if movement_state != MovementState.JUMP:
			movement_state = MovementState.RUN
		facing_left = Input.is_action_pressed("Move_left")
		directionality = -1 if facing_left else 1
	
	if directionality == 0 and movement_state == MovementState.RUN:
		movement_state = MovementState.IDLE
	
	velocity.x = lerp(velocity.x, speed.x * directionality, 0.25)

func change_animation(animation_name = null) :
	var animation_player_node = get_node("/root/Test Level Temp/TileMap/Player/AnimationPlayer") # <<<Really Important
	var movement_name = movement_names[movement_state]
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
