extends CharacterBody3D

const sensitivity = 0.005
const jumpspeed = 10
const walkspeed = 5
var world
var pan

func _ready():
	world = get_parent()
	$Camera3D.rotation.y = randf() * PI * 2
	pan = $Camera3D.rotation

func _physics_process(delta: float):
	for axis in range(2):
		$Camera3D.rotation[axis] += (pan[axis] - $Camera3D.rotation[axis]) * (1 - (2 ** 48) ** -delta)
	var direction = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction += Vector3.FORWARD
	if Input.is_action_pressed("back"):
		direction += Vector3.BACK
	if Input.is_action_pressed("left"):
		direction += Vector3.LEFT
	if Input.is_action_pressed("right"):
		direction += Vector3.RIGHT
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jumpspeed
	if Input.is_action_just_pressed("teleport"):
		position = Vector3(randf_range(-20000, 20000), Global.maxheight + 8, randf_range(-20000, 20000))
		print(position)
	direction = direction.rotated(Vector3.UP, $Camera3D.rotation.y).normalized() * walkspeed
	velocity.x = direction.x
	velocity.z = direction.z
	if position.y <= -0.4:
		velocity *= 0.25 ** delta
		if not is_on_floor():
			velocity.y += 6 * delta
		if Input.is_action_pressed("jump"):
			velocity.y += 10 * delta
	if not is_on_floor():
		velocity.y -= 10 * delta
	move_and_slide()

func _process(delta: float):
	$CanvasLayer.get_node("WaterTint").color = Color.TRANSPARENT if $Camera3D.global_position.y > -0.4 else world.getwatercolor(Vector2(position.x, position.z))

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			pan.y -= event.relative.x * sensitivity
			pan.x -= event.relative.y * sensitivity
			pan.x = clamp(pan.x, -PI * 0.49, PI * 0.49)
