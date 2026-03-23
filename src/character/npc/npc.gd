extends CharacterBody2D
class_name NPC

signal talk_requested(player: CharacterBody2D)
signal talk_finished
signal patrol_point_reached

@onready var sprite: Sprite2D = %Sprite2D
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer
@onready var patrolPoints: Node2D = %PatrolPoints
@onready var idleTimer: Timer = %IdleTimer
@onready var facingTurnTimer: Timer = %FacingTurnTimer

# State
enum NpcState {
	IDLE,
	MOVE,
	PATROL, 
	TALK
}

var state: NpcState = -1 : set = set_state
var current_anim: String

var idleTime := 5.0

@export var patrol_points: Array[Vector2]
var patrol_index := 0

@export var move_speed := 40.0
var direction := Vector2.ZERO
var facing_direction := Vector2.DOWN

func _ready() -> void:
	patrol_points.append(global_position)
	for point in patrolPoints.get_children():
		patrol_points.append(point.global_position)
	state = NpcState.PATROL

func _process(delta: float) -> void:
	_update_animation()

func _physics_process(delta: float) -> void:
	match state:
		NpcState.IDLE:
			_handle_idle_state()
		NpcState.MOVE:
			pass
		NpcState.PATROL:
			_handle_patrol_state(delta)
		NpcState.TALK:
			pass

func set_state(new_state: NpcState) -> void:
	if state == new_state:
		return
	
	state = new_state
	match new_state:
		NpcState.IDLE: _enter_idle_state()
		NpcState.TALK:
			velocity = Vector2.ZERO

func move() -> void:
	if direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		return
	
	facing_direction = direction
	velocity = direction * move_speed
	move_and_slide()

func _handle_idle_state() -> void:
	pass
	
func _handle_patrol_state(delta):
	if patrol_points.is_empty():
		return

	var target = patrol_points[patrol_index]
	direction = target - global_position

	if direction.length() > 2:
		direction = direction.normalized()
		move()
	else:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		patrol_point_reached.emit()

func _update_animation() -> void:
	match state:
		NpcState.IDLE, NpcState.TALK:
			_play_idle_animation()
		NpcState.PATROL:
			_play_move_animation()

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

func _enter_idle_state():
	idleTimer.start(idleTime)
	facingTurnTimer.start(3.0)

func _on_talk_requested(player: CharacterBody2D) -> void:
	set_state(NpcState.TALK)
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
			
func _on_patrol_point_reached() -> void:
	velocity = Vector2.ZERO
	set_state(NpcState.IDLE)

func _on_facing_turn_timer_timeout() -> void:
	if state != NpcState.IDLE:
		return
		
	var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	facing_direction = dirs.pick_random()
	facingTurnTimer.start(3.0)

func _on_idle_timer_timeout() -> void:
	if state != NpcState.IDLE:
		return

	var states = [NpcState.IDLE, NpcState.PATROL]
	state = states.pick_random()
	if state == NpcState.IDLE:
		_enter_idle_state()

func _on_talk_finished() -> void:
	await get_tree().create_timer(2.0).timeout
	set_state(NpcState.IDLE)
