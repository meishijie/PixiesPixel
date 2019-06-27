extends KinematicBody2D

#signal health_updated(health)
#signal killed()
signal throw_item()

const Bomb = preload("res://Characters/Pirate/Bomb.tscn")

const MAX_HEALTH = 100
const RUN_SPEED = 100
const SPRINT_SPEED = 150
const FLOOR = Vector2(0, -1)

const MAX_JUMP_HEIGHT = 7 * 16
const MIN_JUMP_HEIGHT = 2 * 16
const TIME_TO_JUMP_APEX = 0.45

var move_speed : float = RUN_SPEED
var gravity : float
var max_jump_velocity : float
var min_jump_velocity : float
var x_dir : int # direction in which player is facing in the x-axis

var is_grounded : bool = true
var is_attacking : bool = false
var attack_combo : int = 0
var health : int = MAX_HEALTH
var is_dead : bool = false

var velocity : Vector2 = Vector2(0, 0)

puppet var repl_position : Vector2 = Vector2()
puppet var repl_animation : String = "idle"
puppet var repl_scale_x : int = 1

var held_item = null
onready var held_item_position = $Sprite/HeldItemPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity = MAX_JUMP_HEIGHT / pow(TIME_TO_JUMP_APEX, 2)
	max_jump_velocity = -sqrt(2 * gravity * MAX_JUMP_HEIGHT)
	min_jump_velocity = -sqrt(2 * gravity * MIN_JUMP_HEIGHT)
	#$Sprite.get_node("./SwordHitBox/CollisionShape2D").disabled = true # Disables sword hit box on start
	
func _physics_process(delta):

	direction_input()				# horizontal mvmt
	jump_input()					# jump
	acceleration_curve()			# simluate acceleration when moving
	attack_input()
	flip_sprite(x_dir)				# flips sprite when turning direction
	play_animation(x_dir)
		
	$Camera2D.current = true
	velocity.y += gravity * delta 	# gravity
	velocity = move_and_slide(velocity, FLOOR)	# godot's physics
	
	
func direction_input():
	x_dir = 0
	if !is_dead:
		if Input.is_action_pressed("ui_right"):
			x_dir += 1
		if Input.is_action_pressed("ui_left"):
			x_dir += -1
		
# Moves player according to this acceleration curve
func acceleration_curve():
	if !is_attacking:
		if is_on_floor():
			velocity.x = lerp(velocity.x, move_speed * x_dir, 0.2)
		else:
			velocity.x = lerp(velocity.x, move_speed * x_dir, 0.08)
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0, 0.2)
		else:
			velocity.x = lerp(velocity.x, move_speed * x_dir, 0.01)

func attack_input():
	if Input.is_action_pressed("ui_focus_next") && !is_attacking && !is_dead:
		is_attacking = true
		$AnimationPlayer.current_animation = "attack"
	
func jump_input():
	if !is_dead:	
		if Input.is_action_just_pressed("ui_up"):
			if !is_attacking:
				if is_on_floor():
					velocity.y = max_jump_velocity
		
		# variable jump height
		if Input.is_action_just_released("ui_up") && velocity.y < min_jump_velocity:
			velocity.y = min_jump_velocity
			
func flip_sprite(x_dir):
	if x_dir > 0:
		$Sprite.scale.x = 1
	elif x_dir < 0:
		$Sprite.scale.x = -1
		
func play_animation(x_dir):
	if !is_dead:
		if is_on_floor():
			if !is_attacking:
				if x_dir == 0:
					$AnimationPlayer.current_animation = "idle"
				else:
					$AnimationPlayer.current_animation = "run"
		else:
			if !is_attacking:
				if velocity.y < 0:
					$AnimationPlayer.current_animation = "jump"
				if velocity.y > 0:
					$AnimationPlayer.current_animation = "fall"

func _on_AnimationPlayer_animation_finished(attack):
	is_attacking = false

func spawn_rock():
	if held_item == null:		#check if there's already a bomb in hand
		held_item = Bomb.instance()
		held_item_position.add_child(held_item)

func _throw_held_item():
	held_item.launch(x_dir)
	held_item = null
