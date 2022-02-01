extends KinematicBody2D

var speed: float = 300
var direction: Vector2 = Vector2.ZERO
var direction_dict: Dictionary = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

onready var animated_sprite: AnimatedSprite = $AnimatedSprite

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	move_and_slide(direction * speed)

func _input(event: InputEvent) -> void:
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	direction = direction.normalized()
	
	if direction == Vector2.ZERO:
		animated_sprite.stop()
		animated_sprite.set_frame(0)
	else:
		var direction_name = _find_dir_name(direction)
		animated_sprite.play("move_" + direction_name)

func _find_dir_name(dir: Vector2) -> String:
	var direction_values_array = direction_dict.values()
	var direction_index = direction_values_array.find(dir)
	
	if direction_index == -1:
		return ""
	
	var direction_keys_array = direction_dict.keys()
	var direction_key = direction_keys_array[direction_index]
	
	return direction_key
