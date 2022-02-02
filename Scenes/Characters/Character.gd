extends KinematicBody2D
class_name Character

####################
###### ENUMS #######
####################
enum State {
	IDLE,
	MOVE,
	ATTACK
}

####################
#### VARIABLES #####
####################
var speed: float = 300
var moving_direction: Vector2 = Vector2.ZERO setget set_moving_direction, get_moving_direction
var facing_direction: Vector2 = Vector2.DOWN  setget set_facing_direction, get_facing_direction
var direction_dict: Dictionary = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

var state: int = State.IDLE setget set_state, get_state

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var attack_hit_box: Area2D = $AttackHitBox

####################
##### SIGNALS ######
####################
signal state_changed
signal facing_direction_changed
signal moving_direction_changed

####################
#### ACCESSORS #####
####################

func set_state(value: int) -> void:
	if value != state:
		state = value
		emit_signal("state_changed")

func get_state() -> int:
	return state
	
func set_facing_direction(value: Vector2) -> void:
	if value != facing_direction:
		facing_direction = value
		emit_signal("facing_direction_changed")

func get_facing_direction() -> Vector2:
	return facing_direction
	
func set_moving_direction(value: Vector2) -> void:
	if value != moving_direction:
		moving_direction = value
		emit_signal("moving_direction_changed")

func get_moving_direction() -> Vector2:
	return moving_direction

####################
#### BUILT-IN ######
####################
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	move_and_slide(moving_direction * speed)

func _input(event: InputEvent) -> void:
	var local_moving_direction = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	
	set_moving_direction(local_moving_direction.normalized())
	
	if moving_direction != Vector2.ZERO:
		set_facing_direction(moving_direction)
		
	if Input.is_action_just_pressed("ui_accept"):
		set_state(State.ATTACK)
		
	if state != State.ATTACK:
		if moving_direction == Vector2.ZERO:
			set_state(State.IDLE)
		else:
			set_state(State.MOVE)

####################
###### LOGIC #######
####################

# Update the animation based on the current state and facing direction
func _update_animation() -> void:
	var direction_name = _find_dir_name(facing_direction)
	var state_name = ""
	
	match(state):
		State.IDLE: state_name = "idle"
		State.MOVE: state_name = "move"
		State.ATTACK: state_name = "attack"
		
	var anim_name = state_name + "_" + direction_name
	if animated_sprite.get_sprite_frames().has_animation(anim_name):
		animated_sprite.play(anim_name)

# Update the attack hitbox direction based on the current facing direction
func _update_attack_hitbox_direction() -> void:
	var angle = facing_direction.angle()
	attack_hit_box.set_rotation_degrees(rad2deg(angle) - 90)

# Find the name of the given direction and returns it as a string
func _find_dir_name(dir: Vector2) -> String:
	var direction_values_array = direction_dict.values()
	var direction_index = direction_values_array.find(dir)
	
	if direction_index == -1:
		return ""
	
	var direction_keys_array = direction_dict.keys()
	var direction_key = direction_keys_array[direction_index]
	
	return direction_key

func _attack_effect() -> void:
	var bodies_array = attack_hit_box.get_overlapping_bodies()
	
	for body in bodies_array:
		if body.has_method("destroy"):
			body.destroy()

func _interaction_attempt() -> bool:
	var bodies_array = attack_hit_box.get_overlapping_bodies()
	var attempt_success = false
	
	for body in bodies_array:
		if body.has_method("interact"):
			body.interact()
			attempt_success = true
			
	return attempt_success

###############################
###### SIGNAL RESPONSES #######
###############################

func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation.begins_with("attack_"):
		state = State.IDLE

func _on_state_changed() -> void:
	if state == State.ATTACK:
		if _interaction_attempt():
			set_state(State.IDLE)
			
	_update_animation()

func _on_facing_direction_changed() -> void:
	_update_animation()
	_update_attack_hitbox_direction()

func _on_moving_direction_changed() -> void:
	if moving_direction == Vector2.ZERO or moving_direction == facing_direction:
		return

	var sign_dir = Vector2(sign(moving_direction.x), sign(moving_direction.y))
	if sign_dir == moving_direction:
		set_facing_direction(moving_direction)
	else:
		if sign_dir.x == facing_direction.x:
			set_facing_direction(Vector2(0, sign_dir.y))
		else:
			set_facing_direction(Vector2(sign_dir.x, 0))

func _on_AnimatedSprite_frame_changed() -> void:
	if animated_sprite.animation.begins_with("attack_"):
		if animated_sprite.get_frame() == 1:
			_attack_effect()
