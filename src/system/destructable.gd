extends Node
class_name Destructible

@export var max_health := 1
var health := 1

func _ready():
	health = max_health

func take_damage(amount: int, direction: Vector2) -> void:
	health -= amount
	if health <= 0:
		_on_destroyed()

func _on_destroyed() -> void:
	queue_free()
