extends Node
class_name Game

var nb_coins: int = 0 setget set_nb_coins, get_nb_coins

func _ready() -> void:
	EVENTS.connect("coin_collected", self, "_on_EVENTS_coin_collected")
	
func set_nb_coins(value: int) -> void:
	if nb_coins != value:
		nb_coins = value
		EVENTS.emit_signal("nb_coins_changed", nb_coins)
	
func get_nb_coins() -> int:
	return nb_coins
	
func _on_EVENTS_coin_collected() -> void:
	set_nb_coins(nb_coins + 1)
