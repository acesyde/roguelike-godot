extends StaticBody2D
class_name Chest

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D

enum State {
	Idle,
	Open,
	Opened
}

var state: int = State.Idle

func interact() -> void:
	if state != State.Idle:
		return
		
	state = State.Open
	animated_sprite.play("open")

func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "open":
		state = State.Opened

