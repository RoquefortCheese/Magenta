Noise-based infinite procedural generation! Playable at https://roquefortcheese.itch.io/magenta.


Inspirations & Credits:
-  Minecraft
-  Destroying A World That Doesn't Exist
-  GDShader PRNG of unknown origin
-  Ubuntu Mono

Technical explanation:
- 4x4 chunks are loaded around the player in order of radius, at a rate of one per frame.
- Each chunk consists of some meshes generated using a SurfaceTool, their collision objects (created using create_trimesh_collision), and an ArrayMesh for water.
- Each voxel is generated independently of others, except when checking the voxel directly above to determine whether to become stone or moss.
- To prevent any potential recomputations, generated voxels and chunks are stored in dictionaries and reused when possible.
- Voxel generation consists of six simplex noise calls: HEIGHT, BROADHEIGHT, HEIGHTPOWER, CAVES, CAVESSTRENGTH, CAVESDOMAIN, MOSSINESS, and WATERTEMP. (CIVILIZATION was intended to be used to generate structures, but I decided not to implement that in the final version.)
- HEIGHT determines the height of the terrain, BROADHEIGHT determines large-scale elevation, HEIGHTPOWER determines how vertically stretched the terrain height is, CAVES determines the shape of "caves," CAVESSTRENGTH determines how influential caves are, CAVESDOMAIN determines to which extent caves are additive (i.e. floating islands) and subtractive (i.e. actual caves), MOSSINESS determines where there is moss (almost everywhere), and WATERTEMP determines the water color. (For the actual voxel generation code, see the getnatvoxel function in world.gd.)
- Terrain meshes are created by generating each voxel in a chunk, then adding a face to the mesh of the corresponding material for each face of a non-air voxel that borders air.
- The water is controlled by a shader which makes each vertex move in a sinusoidal way with a random input offset. (This is where I used the credited PRNG.)
- The sky is also controlled by a shader.

I made this for no particular reason other than wanting to make something, liking the concept of procedural infinite world generation, and having a particular visual aesthetic in mind. I didn't turn it into a complete game because I didn't have any interesting ideas, I was already worrying about lag far more than I would like to, generating multi-chunk structures over an infinite world is difficult, and there is only so much fun to be had from wandering the same world forever.

AI Use:
I used AI a bit for documentation and debugging. All code is handwritten.
