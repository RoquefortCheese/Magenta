extends Node

# constant project-specific variables
const chunksize = 4
const minheight = -64; const maxheight = 64
enum Vox {AIR, STONE, MOSS}
enum Mat {STONE, MOSS, SIDEMOSS}
@export var materials: Dictionary[Mat, StandardMaterial3D]
@export var sidematerials: Dictionary[Vox, Mat]
@export var topmaterials: Dictionary[Vox, Mat]
@export var bottommaterials: Dictionary[Vox, Mat]
