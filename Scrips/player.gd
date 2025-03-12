extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var main = $"../"

var speed_current = 0
var direction = Vector3.ZERO
var initial_head_pos: float

@export var walk_speed = 5.0
@export var sprint_speed = 10.0
@export var crouch_speed = 3.0
@export var jump_velocity = 2.5
@export var lerp_speed = 5.0
@export var mouse_sens = 0.4
@export var crouch_depth = 0.9


func _ready() -> void:
	initial_head_pos = head.position.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !main.paused:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouch") and is_on_floor():
		speed_current = crouch_speed
		head.position.y = lerp(head.position.y, initial_head_pos - crouch_depth, delta*lerp_speed)
		standing_collision.disabled = true
		crouching_collision.disabled = false
	elif !ray_cast_3d.is_colliding():
		standing_collision.disabled = false
		crouching_collision.disabled = true
		head.position.y = lerp(head.position.y, initial_head_pos, delta*lerp_speed)
		if Input.is_action_pressed("sprint") and is_on_floor():
			speed_current = sprint_speed
		elif is_on_floor():
			speed_current = walk_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if direction:
		velocity.x = direction.x * speed_current
		velocity.z = direction.z * speed_current
	else:
		velocity.x = move_toward(velocity.x, 0, speed_current)
		velocity.z = move_toward(velocity.z, 0, speed_current)

	move_and_slide()
