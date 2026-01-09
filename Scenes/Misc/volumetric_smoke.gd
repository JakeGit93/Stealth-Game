extends Node3D

@export var grid_width := 128
@export var grid_height := 128
@export var grid_depth := 128
@export var voxel_size := 0.5
@export_range(1,64) var chunk_size := 64
@export var debug := true

@onready var grid_origin := self.global_position

func _ready():
	_generate_grid()

#we need to export a chunk as a PackedByteArray to write to file
#also need to make the loop only generate one chunk at a time, and then remove it from memory (after writing it)
func _generate_grid():
	var shared_mesh := BoxMesh.new()
	
	var half_extent_x := (grid_width * voxel_size) * 0.5
	var half_extent_y := (grid_height * voxel_size) * 0.5
	var half_extent_z := (grid_depth * voxel_size) * 0.5

	for x in grid_width:
		for y in grid_height:
			for z in grid_depth:
				var local_pos := Vector3(
					x * voxel_size - half_extent_x + voxel_size * 0.5,
					y * voxel_size - half_extent_y + voxel_size * 0.5,
					z * voxel_size - half_extent_z + voxel_size * 0.5
				)
				
				var world_pos := global_transform * local_pos
				var occupied : bool = _voxel_intersects_geometry(world_pos)
				
					
				if occupied && debug == true:
					var shared_cube := MeshInstance3D.new()
					shared_cube.mesh = shared_mesh
					var mat := StandardMaterial3D.new()
					shared_cube.scale = Vector3.ONE * voxel_size * 0.99
					mat.albedo_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1.0)
					shared_cube.position = local_pos
					shared_cube.set_surface_override_material(0, mat)
					add_child(shared_cube)
					
				#un-comment this if you want the debug vis
				#if use_wireframe_debug:
					# Global wireframe debug mode
					#RenderingServer.set_debug_generate_wireframes(true)
					#get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME

func _voxel_intersects_geometry(world_pos: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE * voxel_size
	
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, world_pos)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = 0xFFFFFFFF

	
	var result := space_state.intersect_shape(query, 1)
	if result.size() > 0:
		return true
	else:
		return false

func _write_header(file: FileAccess) -> void:
	#this header is **not** for storing any chunk data or occupancy values!
	file.seek(0)

	# Magic
	file.store_string("VXL")       
	file.store_8(0)                # null terminator

	# Version
	file.store_8(1)

	# Header size (fixed)
	file.store_32(37)

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

func _write_grid_to_file(chunk: PackedByteArray) -> void:
	var path := "res://Assets/Volumes/TestVolume.vlx"
	var file := FileAccess.file_exists(path)

	if file:
		pass
	else:
		#write the header because the file doesn't exist yet
		_write_header(FileAccess.open(path, FileAccess.WRITE))

		#write the rest of the data down here eventually...
		
func _bake_chunk(chunk: PackedByteArray) -> void:
	_write_grid_to_file(chunk)
