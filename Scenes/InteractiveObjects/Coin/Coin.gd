extends Node2D
class_name Coin

enum State {
	Idle,
	Follow,
	Collect
}

var speed: float = 400.0
var state: int = State.Idle
var target: Node2D = null

onready var area : Area2D = $Area2D
onready var coin_sprite: AnimatedSprite = $CoinSprite
onready var shadow_sprite: AnimatedSprite = $ShadowSprite
onready var particules: Particles2D = $Particles2D
onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("wave")

func _physics_process(delta: float) -> void:
	if state == State.Follow:
		var target_pos = target.get_position()
		var move_speed = speed * delta
		
		if position.distance_to(target_pos) < move_speed:
			position = target_pos
			collect()
		else:
			position = position.move_toward(target_pos, move_speed)

func collect() -> void:
	state = State.Collect
	coin_sprite.set_visible(false)
	shadow_sprite.set_visible(false)
	particules.set_emitting(true)
	audio_stream.play()
	
	EVENTS.emit_signal("coin_collected")
	
	yield(audio_stream, "finished")
	queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
	if state == State.Idle:
		state = State.Follow
		target = body
		animation_player.stop()

func _on_Timer_timeout() -> void:
	if state == State.Idle:
		coin_sprite.play("rotate")
		shadow_sprite.play("rotate")

func _on_CoinSprite_animation_finished() -> void:
	if coin_sprite.get_animation() == "rotate":
		coin_sprite.play("idle")
		shadow_sprite.play("idle")
