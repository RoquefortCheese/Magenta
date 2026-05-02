extends Node

const cardinals = [Vector3.UP, Vector3.DOWN, Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]
const bases = {
	Vector3.UP: Basis(Vector3.RIGHT, Vector3.UP, Vector3.BACK),
	Vector3.DOWN: Basis(Vector3.LEFT, Vector3.DOWN, Vector3.BACK),
	Vector3.RIGHT: Basis(Vector3.FORWARD, Vector3.RIGHT, Vector3.DOWN),
	Vector3.LEFT: Basis(Vector3.BACK, Vector3.LEFT, Vector3.DOWN),
	Vector3.FORWARD: Basis(Vector3.LEFT, Vector3.FORWARD, Vector3.DOWN),
	Vector3.BACK: Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN)
}
var matmap = {-1: Global.bottommaterials, 0: Global.sidematerials, 1: Global.topmaterials}
@export var square: PlaneMesh

var world: Node
var surfacetools: Dictionary[Global.Mat, SurfaceTool]
var loaded: bool

func create(position: Vector2):
	var start = Time.get_ticks_msec()
	world = get_parent()
	for mattype in Global.Mat.values():
		surfacetools[mattype] = SurfaceTool.new()
		surfacetools[mattype].begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(position.x, position.x + Global.chunksize):
		for z in range(position.y, position.y + Global.chunksize):
			for y in range(Global.minheight, Global.maxheight + 1):
				var point = Vector3(x, y, z)
				var voxel = world.generated[point]
				if voxel != Global.Vox.AIR:
					for disp in cardinals:
						if world.getnatvoxel(point + disp) == Global.Vox.AIR:
							var basis = bases[disp]
							var origin = point + Vector3.ONE / 2. + disp / 2.
							var st = surfacetools[matmap[int(disp.y)][voxel]]
							st.append_from(square, 0, Transform3D(basis, origin))
	for mattype in Global.Mat.values():
		var instance = MeshInstance3D.new()
		instance.mesh = surfacetools[mattype].commit()
		if instance.mesh.get_surface_count() != 0:
			instance.mesh.surface_set_material(0, Global.materials[mattype])
			instance.create_trimesh_collision()
		add_child(instance)
	var watertool = SurfaceTool.new()
	watertool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(position.x, position.x + Global.chunksize + 1):
		for z in range(position.y, position.y + Global.chunksize + 1):
			watertool.set_color(world.getwatercolor(Vector2(x, z)))
			watertool.add_vertex(Vector3(x, 0, z))
	for x in range(Global.chunksize):
		for z in range(Global.chunksize):
				for i in range(4):
					for a in range(4):
						if a != i:
							watertool.add_index((x + a % 2) + (z + a / 2) * (Global.chunksize + 1))
	$WaterMesh.mesh = watertool.commit()
