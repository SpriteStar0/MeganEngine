# This is the Player script. Most of the big logic will be handled in here
# since the Player (character) is the entity the player (human) will control
# the most.

extends Actor
# These are constants and by convention, they are capitalized and exported
# so the editor can see and change the values. Generally, these values will
# not change at run time (when the game is active).
export var RATE_OF_FIRE = 0.25
export var DASH_FACTOR = 12
export var DASH_LENGTH = 0.2
export var DASH_COOLDOWN = 1
export var MAX_NUMBER_OF_JUMPS = 2
export var ENTITY_NAME = "Claire"
# This is a PackedScene that we will instantiate to make a "bullet". 
const normal_projectile = preload("res://Projectile.tscn")
# Most - if not all - of the special actions will have a pair of Booleans in
# the form of "can" and "is": one represents the ability to start the action
# and the other represents the action happening at that moment. This makes it
# easier to make animations that need to take multiple movement states into
# account.
var can_attack = true
var is_attacking = false
var can_dash = true
var is_dashing = false
# As you already know, directionality is a special case but it follows the same
# ideal as what was mentioned above.
var directionality = 0
var facing_left = false
# These variables are all changeable and represent the state of certain actions
# involving the player.
var number_of_jumps = MAX_NUMBER_OF_JUMPS
# Each one of these groups represent a number of states, their corresponding
# string literal, and a default state. These are used to figure out the correct
# animation based on which booleans are true or not. The alternative method is
# to create a AnimationTree (which is the more conventional way) but it would
# still require you to list out all the states and all the animations in a way
# that seemed overkill for what we need. However, in the event we just can't
# figure out how to make something happen, that would be the approach to take.
enum MovementState {IDLE, RUN, JUMP, DASH, WALL_SLIDE, HOVER}
var movement_names =  ["Idle", "Run", "Jump", "Dash", "Wallslide", "Hover"]
var movement_state = MovementState.IDLE

enum WeaponType {DEFAULT, SKILL}
var weapon_names = ["Default", "Skill"]
var weapon_type = WeaponType.DEFAULT

enum SkillType {SKILL_1, SKILL_2, SKILL_3}
var skill_names = ["Unga", "Bunga", "E"]
var skill_type = null
# This is the _process() function that is specific to the player. At the moment,
# it simply calls all of these handling functions and lets them do the heavy
# lifting, so to speak. NOTE: The order of these functions matters.
func _process(_delta):
	# This function should handle any special/contextual actions the player
	# can take.
	handle_special_actions()
	# Self-explanatory.
	handle_attacking()
	handle_movement()
	# This function is for handling global or game-level inputs like "quit".
	handle_other_input()
	# The very last thing we call is the change_animation() function which
	# begins the process of determining if we need to change the animation
	# based on the booleans that are set. 
	change_animation()
	
# Nothing in here at the moment.
func handle_special_actions():
	pass
	
# Self-explanatory.
func handle_attacking():
	# TODO: Change the name of this action to "Attack" since there is no
	# guarantee that every weapon is going to be a gun/rifle/cannon.
	if Input.is_action_pressed("Shoot"):
		is_attacking = true
		if can_attack:
			can_attack = false
			# This timer is linked to the RATE_OF_FIRE constant above. Think of
			# it as a bullet delay. At the moment, this works for certain
			# states but it's a problem when the attack needs to be synced up
			# with the animation separately. I know the current bandage is to
			# manually keyframe the function calls but we need to revisit that
			# soon.
			var attack_timer = Timer.new()
			attack_timer.one_shot = true
			attack_timer.wait_time = RATE_OF_FIRE
			attack_timer.connect("timeout", self, "set_can_attack", [true])
			add_child(attack_timer)
			attack_timer.start()
	else:
		is_attacking = false
		
func handle_movement():
	# The first thing we want to check is if we're pressing "Move_left" or 
	# "Move_right". That will be the first thing to determine directionality.
	if Input.is_action_pressed("Move_left") or Input.is_action_pressed("Move_right"):
		# We don't want to interrupt the dash since it's a higher priority than
		# running left or right.
		if not is_dashing:
			# We assign this here so you can't change direction mid-dash.
			facing_left = Input.is_action_pressed("Move_left")
			# If we're touching the floor, we can safely switch to RUN.
			if is_on_floor():
				movement_state = MovementState.RUN
			# Otherwise, we jump.
			else:
				movement_state = MovementState.JUMP
		directionality = -1 if facing_left else 1
	else:
		directionality = 0

	if Input.is_action_pressed("Dash"):
		# In the event we pressed "Dash" without a direction, we determine
		# directionality here before proceeding with the dash.
		directionality = -1 if facing_left else 1
		dash()
	
	# Jumping is wily. Generally, jump should override all non-dash actions
	# but we need to also reset the player when they touch the floor again. If
	# the player is still in the air, they need to still be in the jump
	# animation.
	if Input.is_action_just_pressed("Jump"):
		jump()
	elif is_on_floor():
		# If we're not moving left or right and we're on the floor...
		if directionality == 0:
			movement_state = MovementState.IDLE
		number_of_jumps = MAX_NUMBER_OF_JUMPS
	elif not is_on_floor():
		movement_state = MovementState.JUMP
	# Dash is the highest priority animation. This assigns the state if we
	# are dashing but if we aren't, it's just a passthrough.
	movement_state = MovementState.DASH if is_dashing else movement_state
	# Finally, we do the calculations to find the new X-velocity.
	velocity.x = lerp(velocity.x, speed.x * directionality, 0.25)
	
# Self-explanatory.
func handle_other_input():
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()

func change_animation(animation_name = null):
	# First, we grab the animation player node for the Player.
	var animation_player_node = get_node("/root/Test Level Temp/TileMap/Player/AnimationPlayer") # <<<Really Important
	# Then, we get the string literals for each state based on the enums we
	# have.
	var movement_name = movement_names[movement_state]
	var attack_name = "Attack" if is_attacking else ""
	var weapon_name = weapon_names[weapon_type]
	var skill_name = "" if skill_type == null else skill_names[skill_type]
	# We determine the direction based on if we're facing left.
	var direction_name = "L" if facing_left else "R"
	# We stuff all the strings into an array that we'll use in a f-string later.
	var all_names = [
		ENTITY_NAME,
		movement_name,
		attack_name,
		weapon_name,
		skill_name,
		direction_name
	]
	
	var current_animation_name = animation_player_node.current_animation
	# "The next animation will be <this> if it isn't <this> already."
	var next_animation_name = animation_name if animation_name else "%s%s%s%s%s_%s" % all_names
	# Do we even have that animation?
	if animation_player_node.has_animation(next_animation_name):
		# "We do and we're already in it."
		if current_animation_name == next_animation_name and animation_player_node.is_playing():
			pass
		# "We do but we're doing something else."
		else:
			print("Animation changed: %s" % next_animation_name)
			animation_player_node.play(next_animation_name)
			animation_player_node.advance(0)
			# Reset the player if we had something in there.
			if current_animation_name:
				var start_time = animation_player_node.current_animation_position
				animation_player_node.seek(round(min(start_time, animation_player_node.current_animation_length)))
	else:
		# "We don't have that animation. Yell."
		print("Missing animation! %s" % next_animation_name)

func dash():
	if can_dash:
		can_dash = false
		is_dashing = true
		# Dashing - by definition - is a sudden increase in X velocity. Keeping
		# that in mind, this adds that impulse to X velocity.
		velocity.x += directionality * (speed.x * DASH_FACTOR)
		# We want the dash to be unaffected by gravity so we need to set that
		# variable AND we need to remove any Y-velocity we had.
		velocity.y = 0
		self.is_affected_by_gravity = false
		# This is a timer for ending the dash which is separate from the
		# dash cooldown below. If someone mashes dash while unaffected by
		# gravity, they could just skip stages.
		var dash_timer = Timer.new()
		dash_timer.one_shot = true
		dash_timer.wait_time = DASH_LENGTH
		dash_timer.connect("timeout", self, "end_dash")
		add_child(dash_timer)
		dash_timer.start()
		# Dash cooldown, as mentioned above.
		var cooldown_timer = Timer.new()
		cooldown_timer.one_shot = true
		cooldown_timer.wait_time = DASH_COOLDOWN
		cooldown_timer.connect("timeout", self, "set_can_dash", [true])
		add_child(cooldown_timer)
		cooldown_timer.start()

func jump():
	# The player should be able to jump as long as they have jumps left.
	if number_of_jumps > 0:
		movement_state = MovementState.JUMP
		# We need to halt the Y-velocity first because we don't know if
		# they're double- or triple-jumping.
		velocity.y = 0
		velocity.y -= speed.y
		number_of_jumps -= 1

# This function is only meant to be called by the jumping animations. This will
# loop the last few frames until the player hits the ground.
func loop_falling():
	if is_on_floor() and movement_state == MovementState.JUMP:
		movement_state = MovementState.IDLE
		change_animation()
	else:
		$AnimationPlayer.seek(0.4)

# Self-explanatory.
func set_can_attack(enabled):
	can_attack = enabled

func set_can_dash(enabled):
	can_dash = enabled

func end_dash():
	is_dashing = false
	self.is_affected_by_gravity = true

func shoot_gun():
	var spawn_point = $BulletSpawnL if facing_left else $BulletSpawnR
	var normal_projectile_instance = normal_projectile.instance()
	normal_projectile_instance.direction = -1 if facing_left else 1
	normal_projectile_instance.position = spawn_point.global_position
	get_parent().add_child(normal_projectile_instance)
