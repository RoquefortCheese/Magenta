extends Node

@export var chunkscene: PackedScene

const flatcardinals = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
const loadradius = 96
const keepmargin = 0
const buildlength = 16
enum NoiseType {HEIGHT, BROADHEIGHT, HEIGHTPOWER, CAVES, CAVESSTRENGTH, CAVESDOMAIN, MOSSINESS, WATERTEMP, CIVILIZATION}
var noisefreqs = {
	NoiseType.HEIGHT: 0.01,
	NoiseType.BROADHEIGHT: 0.001,
	NoiseType.HEIGHTPOWER: 0.00125,
	NoiseType.CAVES: 0.01,
	NoiseType.CAVESSTRENGTH: 0.00125,
	NoiseType.CAVESDOMAIN: 0.00125,
	NoiseType.MOSSINESS: 0.0025,
	NoiseType.WATERTEMP: 0.0005,
	NoiseType.CIVILIZATION: 0.0025,
}
enum BuildInfo {ROOMS, MINXY, MAXXY, FLOOR, CEILING, DOORPOS, DOORHEIGHT}

var noises: Dictionary[NoiseType, FastNoiseLite]
var generated: Dictionary[Vector3, Global.Vox]
var colnoise: Dictionary[Vector2, float]
var chunks: Dictionary[Vector2, Node]
var buildmetadata: Dictionary
var currentradius = 0
var loadqueue = []
var terrainseed = randi()
var dice = RandomNumberGenerator.new()

func signexponent(n: float, power: float):
	return sign(n) * abs(n) ** power

func todomain(value: float, minval: float, maxval: float):
	return value * (maxval - minval) / 2 + (maxval + minval) / 2

func getcolnoise(point: Vector2, noise: NoiseType):
	if point in colnoise:
		return colnoise[point]
	colnoise[point] = noises[noise].get_noise_2d(point.x, point.y)
	return colnoise[point]

func getnatvoxel(point: Vector3):
	if point in generated:
		return generated[point]
	var finalresult
	if point.y <= Global.minheight:
		finalresult = Global.Vox.STONE
	if point.y > Global.maxheight:
		finalresult = Global.Vox.AIR
	if finalresult == null:
		var col = Vector2(point.x, point.z)
		var stepone = getcolnoise(col, NoiseType.HEIGHT)
		var steptwo = stepone + sin(getcolnoise(col, NoiseType.BROADHEIGHT) * PI / 2) * 2
		var stepthree = 2 ** todomain(getcolnoise(col, NoiseType.HEIGHTPOWER), 3, 5)
		var stepfour = signexponent(point.y / stepthree - steptwo, 0.5) - signexponent(1 / tan((point.y - Global.minheight) / (Global.maxheight + 1 - Global.minheight) * PI) / 8, 8)
		var stepfive = noises[NoiseType.CAVES].get_noise_3d(point.x, point.y, point.z)
		var stepsix = stepfive * 0.5 + getcolnoise(col, NoiseType.CAVESDOMAIN) * 0.25
		var stepseven = stepsix * todomain(getcolnoise(col, NoiseType.CAVESSTRENGTH), 0, 8)
		var stepeight = stepfour + stepseven
		finalresult = Global.Vox.STONE if stepeight <= 0 else Global.Vox.AIR
		if finalresult == Global.Vox.STONE and getnatvoxel(point + Vector3.UP) == Global.Vox.AIR:
			var stepnine = todomain(getcolnoise(col, NoiseType.MOSSINESS), -0.25, 1)
			var stepten = stepnine + min(0, point.y / 8.)
			if stepten > 0:
				finalresult = Global.Vox.MOSS
	generated[point] = finalresult
	return finalresult

func genchunk(position: Vector2):
	for x in range(position.x, position.x + Global.chunksize):
		for z in range(position.y, position.y + Global.chunksize):
			for y in range(Global.minheight, Global.maxheight + 1):
				getnatvoxel(Vector3(x, y, z))

func getbuildchunk(position: Vector2):
	var offset = floor(position.x / buildlength) * Global.chunksize
	return Vector2(floor(position.x / buildlength) * buildlength, floor((position.y + offset) / buildlength) * buildlength - offset)

func getwatercolor(point: Vector2):
	return Color(0, noises[NoiseType.WATERTEMP].get_noise_2d(point.x, point.y) * 0.5 + 0.5, 1, 0.5)

func noisesetup():
	dice.seed = terrainseed
	for noise in NoiseType.values():
		noises[noise] = FastNoiseLite.new()
		noises[noise].noise_type = FastNoiseLite.TYPE_SIMPLEX
		noises[noise].seed = dice.randi()
		noises[noise].frequency = noisefreqs[noise]

func _ready():
	noisesetup()
	genloadqueue()

func loadchunk(position: Vector2):
	var start = Time.get_ticks_msec()
	if position in chunks:
		var chunk = chunks[position]
		if chunk.loaded:
			return
		chunk.loaded = true
		add_child(chunk)
		return
	genchunk(position)
	var chunk = chunkscene.instantiate()
	add_child(chunk)
	chunk.create(position)
	chunk.loaded = true
	chunks[position] = chunk
	return


func unloadchunk(position: Vector2):
	if chunks[position].loaded:
		chunks[position].loaded = false
		remove_child(chunks[position])

func _input(event: InputEvent):
	if event.is_action("leftclick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func genloadqueue():
	var playerchunk = Vector2(floor(float($Player.position.x / Global.chunksize)) * Global.chunksize, floor(float($Player.position.z / Global.chunksize)) * Global.chunksize)
	loadqueue = []
	for x in range(-currentradius, currentradius + 1):
		for z in range(-currentradius, currentradius + 1):
			if abs(x) == currentradius or abs(z) == currentradius:
				var chunk = Vector2(x * Global.chunksize, z * Global.chunksize) + playerchunk
				if chunk not in chunks or not chunks[chunk].loaded:
					loadqueue.append(chunk)

func _process(delta: float):
	var playerchunk = Vector2(floor(float($Player.position.x / Global.chunksize)) * Global.chunksize, floor(float($Player.position.z / Global.chunksize)) * Global.chunksize)
	for chunk in chunks:
		var difference = abs(playerchunk - chunk)
		if max(difference.x, difference.y) > loadradius + keepmargin:
			unloadchunk(chunk)
	var foundradius = false
	for radius in range(currentradius):
		for x in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				if abs(x) == radius or abs(z) == radius:
					var chunk = Vector2(x * Global.chunksize, z * Global.chunksize) + playerchunk
					if chunk not in chunks or not chunks[chunk].loaded:
						foundradius = true
						currentradius = radius
						break
			if foundradius:
				break
		if foundradius:
			break
	if foundradius:
		genloadqueue()
	if len(loadqueue) != 0:
		var loading = loadqueue.pick_random()
		loadchunk(loading)
		loadqueue.erase(loading)
		if len(loadqueue) == 0 and currentradius < loadradius / Global.chunksize:
			currentradius += 1
			genloadqueue()
