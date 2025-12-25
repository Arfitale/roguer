extends Node
class_name Destructable

@export var max_health: int = 1
@export var health := max_health: 
	get():
		return health
	set(value):
		health = clampi(value, 0, max_health)
		if health == 0:
			print(true)
			_on_health_empty()

func _ready() -> void:
	health = max_health

func take_damage(damage: int) -> void:
	pass

func _on_health_empty() -> void:
	pass
