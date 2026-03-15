extends CharacterBody2D
class_name NPC

signal talk_requested(player: CharacterBody2D)

@onready var sprite: Sprite2D = %Sprite2D
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer

# State
enum NpcState {
	IDLE,
	MOVE, 
	TALK
}

var state: NpcState = -1 : set = set_state
var current_anim: String

@export var speed := 40.0
var input_direction := Vector2.ZERO
var facing_direction := Vector2.DOWN

func _ready() -> void:
	state = NpcState.IDLE

func _process(delta: float) -> void:
	_update_animation()

func _physics_process(delta: float) -> void:
	match state:
		NpcState.IDLE:
			_handle_idle_state()
		NpcState.MOVE:
			_handle_move_state()

func set_state(new_state: NpcState) -> void:
	if state == new_state:
		return
	
	state = new_state

func _handle_idle_state() -> void:
	pass

func _handle_move_state() -> void:
	pass

func _update_animation() -> void:
	match state:
		NpcState.IDLE, NpcState.TALK:
			_play_idle_animation()

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

func _on_talk_requested(player: CharacterBody2D) -> void:
	var relative_direction := player.global_position - global_position
	if abs(relative_direction.x) > abs(relative_direction.y):
		if relative_direction.x > 0:
			facing_direction = Vector2.RIGHT
		else:
			facing_direction = Vector2.LEFT
	else:
		if relative_direction.y > 0:
			facing_direction = Vector2.DOWN
		else:
			facing_direction = Vector2.UP
			
	set_state(NpcState.TALK)
