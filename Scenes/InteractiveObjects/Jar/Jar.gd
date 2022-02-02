extends StaticBody2D
class_name Jar

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D

enum State {
	Idle,
	Breaking,
	Broken
}

var state: int = State.Idle

func destroy() -> void:
	if state != State.Idle:
		return
		
	state = State.Breaking
	animated_sprite.play("break")

func _on_AnimatedSprite_animation_finished() -> void:
	if animated_sprite.animation == "break":
		state = State.Broken
		collision_shape.set_disabled(true)
