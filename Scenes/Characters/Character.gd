extends KinematicBody2D

var speed: float = 300
var moving_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN
var direction_dict: Dictionary = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

var is_attacking: bool = false
var is_moving: bool = false

onready var animated_sprite: AnimatedSprite = $AnimatedSprite

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	move_and_slide(moving_direction * speed)

func _input(event: InputEvent) -> void:
	moving_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	moving_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	moving_direction = moving_direction.normalized()
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction
		
	var direction_name = _find_dir_name(facing_direction)
	
	if Input.is_action_just_pressed("ui_accept"):
		is_attacking = true
		
	if is_attacking:
		# Attack animation
		var anim_name = "attack_" + direction_name
		if animated_sprite.get_sprite_frames().has_animation(anim_name):
			animated_sprite.play(anim_name)
	else:
		# Idle animation
		if moving_direction == Vector2.ZERO:
			animated_sprite.stop()
			animated_sprite.set_frame(0)
		# Move animation
		else:
			is_moving = true
			var anim_name = "move_" + direction_name
			if animated_sprite.get_sprite_frames().has_animation(anim_name):
				animated_sprite.play(anim_name)

func _find_dir_name(dir: Vector2) -> String:
	var direction_values_array = direction_dict.values()
	var direction_index = direction_values_array.find(dir)
	
	if direction_index == -1:
		return ""
	
	var direction_keys_array = direction_dict.keys()
	var direction_key = direction_keys_array[direction_index]
	
	return direction_key


func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation.begins_with("attack_"):
		is_attacking = false
		
		var direction_name = _find_dir_name(facing_direction)
	
		animated_sprite.set_animation("move_" + direction_name)
		animated_sprite.stop()
		animated_sprite.set_frame(0)
