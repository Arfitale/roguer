extends CharacterBody2D
class_name NPC

@onready var sprite: Sprite2D = %Sprite2D
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer
# State
enum NpcState {
	IDLE,
	MOVE, 
	INTERACT, 
	TALK
}
var state := NpcState.IDLE

var current_anim: String

@export var speed := 40.0
var input_direction := Vector2.ZERO
var facing_direction := Vector2.DOWN


func _process(delta: float) -> void:
	_update_animation()

func _physics_process(delta: float) -> void:
	match state:
		NpcState.IDLE:
			_handle_idle_state()
		NpcState.MOVE:
			_handle_move_state()

func _handle_idle_state() -> void:
	pass

func _handle_move_state() -> void:
	pass

func _update_animation() -> void:
	pass

func _play_animation(animation: String):
	if animation == current_anim:
		return
	
	current_anim = animation
	animationPlayer.play(animation)

func _direction_to_anim(prefix: String, direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		return prefix + ("_right" if direction.x > 0 else "_left")
	else:
		return prefix + ("_down" if direction.y > 0 else "_up")

func _play_move_animation():
	_play_animation(_direction_to_anim("move", facing_direction))

func _play_idle_animation():
	_play_animation(_direction_to_anim("idle", facing_direction))

func _on_interaction_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
