# TODO

# Functions are calling each other too much, we should provide the functions with the class agnostically
# and let the class instance do the logic.

# Require a vxl resource per Volume3D object?

# 3D noise textures (etc) should be resources of objects that interface with Volume3D

# Extend per-voxel values for lighting system?

# Add greedy mesher

# Add noise3D support

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@tool

class_name Volume3D extends Node3D

@export var grid_width := 128
@export var grid_height := 128
@export var grid_depth := 128
@export var voxel_size := 0.5
@export var debug := false
@export var test_object : Node3D

@onready var grid_origin := self.global_position
@onready var shared_mesh := BoxMesh.new()
@onready var shared_mat := StandardMaterial3D.new()

func _ready():
	var grid := generate_grid()
	write_grid_to_file(grid)

	var voxel_voxelspace := worldspace_to_voxelspace(test_object.position)
	var voxel_pos := get_voxel_position(voxel_voxelspace)
	visualize_voxel(voxel_pos)

	#read_file("res://Assets/Volumes/TestVolume.vxl")

func _physics_process(_delta: float) -> void:
	pass

func generate_grid() -> PackedByteArray:
	var grid_array := PackedByteArray()
	

	for z in grid_depth:
		for y in grid_height:
			for x in grid_width:
				var local_pos := Vector3(
					x * voxel_size,
					y * voxel_size,
					z * voxel_size
				)
				
				var world_pos := global_transform * local_pos
				var occupied : bool = voxel_intersects_geometry(world_pos)

				#creating the array of occupied values
				if occupied == true:
					grid_array.append(1)
				else:
					grid_array.append(0)

				#debug visuals
				if occupied && debug == true:
					visualize_occupied(local_pos)

	return grid_array

func voxel_intersects_geometry(world_pos: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE * voxel_size
	
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, world_pos)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = 0xFFFFFFFF #maybe we don't want to set this manually just in case there are objects not on this layer

	
	var result := space_state.intersect_shape(query, 1)
	if result.size() > 0:
		return true
	else:
		return false

func write_header(file: FileAccess) -> void:
	#this header is **not** for storing any chunk data or occupancy values!
	file.seek(0)

	# Magic
	file.store_pascal_string("vxl")       

	# Version
	file.store_8(1)

	# Voxel size
	file.store_float(voxel_size)

	# Grid origin (world-space)
	file.store_float(grid_origin.x)
	file.store_float(grid_origin.y)
	file.store_float(grid_origin.z)

	# Grid dimensions (total grid size)
	file.store_32(grid_width)
	file.store_32(grid_height)
	file.store_32(grid_depth)

#gonna have to redo this potentially?
func write_grid_to_file(grid: PackedByteArray) -> void:
	var path := "res://Assets/Volumes/TestVolume.vxl"

	var file := FileAccess.open(path, FileAccess.WRITE_READ)
	write_header(file)
	file.store_buffer(grid)
	file.close()

#and this?
func read_file(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var file_type := file.get_pascal_string()
	var grid_data: PackedByteArray

	print("read file has started")

	if file_type != "vxl":
		assert(file_type == "vxl", "file type incorrect")
		return null
	else:
		print("vxl")

		var version := file.get_8()
		print("version: ", version)

		var voxel_size_temp := file.get_float()
		print("voxel size: ", voxel_size_temp)

		var grid_origin_x := file.get_float()
		print("grid origin x: ", grid_origin_x)

		var grid_origin_y := file.get_float()
		print("grid origin y: ", grid_origin_y)

		var grid_origin_z := file.get_float()
		print("grid origin z: ", grid_origin_z)

		var grid_size_x_temp := file.get_32()
		print("grid size x: ", grid_size_x_temp)

		var grid_size_y_temp := file.get_32()
		print("grid size y: ", grid_size_y_temp)

		var grid_size_z_temp := file.get_32()
		print("grid size z: ", grid_size_z_temp)

		#the data after the header gets returned as a packedbytearray
		var remaining_data := file.get_length() - file.get_position()
		grid_data = file.get_buffer(remaining_data)
		return grid_data

func worldspace_to_voxelspace(pos: Vector3) -> Vector3i:
	var origin := self.position 
	var object_voxel_position : Vector3i = floor(pos - origin / voxel_size)
	return object_voxel_position

func get_voxel_position(index: Vector3i) -> Vector3:
	var current_pos := grid_origin
	for z in index.z:
		current_pos.z += voxel_size
	for y in index.y:
		current_pos.y += voxel_size
	for x in index.x:
		current_pos.x += voxel_size

	print("voxel world position: ", current_pos)
	return current_pos

func visualize_occupied(pos: Vector3) -> void:
	var shared_cube := MeshInstance3D.new()
	shared_cube.mesh = shared_mesh
	var mat := StandardMaterial3D.new()
	shared_cube.scale = Vector3.ONE * voxel_size * 0.99
	mat.albedo_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1.0)
	shared_cube.position = pos
	shared_cube.set_surface_override_material(0, mat)
	add_child(shared_cube)
					
	#wireframe visuals
	#~~~~~~~~~~~~~~
	#if use_wireframe_debug:
		#RenderingServer.set_debug_generate_wireframes(true)
		#get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME

#we need to query the grid, and insert the mesh that aligns with the voxel position.	
func visualize_voxel(pos: Vector3i) -> void:
	var cube := MeshInstance3D.new()
	cube.mesh = shared_mesh
	cube.scale = Vector3.ONE * voxel_size * 0.99
	shared_mat.albedo_color = Color(255,0,0)
	cube.position = worldspace_to_voxelspace(pos)
	print("voxel grid position: ", pos)
	#cube.set_surface_override_material(0, shared_mat)
	add_child(cube)
