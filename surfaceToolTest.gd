@tool

extends Node3D

var st = SurfaceTool.new()
var mesh_instance := MeshInstance3D.new()

func _ready() -> void:
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	st.set_normal(Vector3.UP)
	st.add_vertex(Vector3(0,0,0))
	st.add_vertex(Vector3(1,0,0))
	st.add_vertex(Vector3(1,0,1))

	st.add_vertex(Vector3(0,0,0))
	st.add_vertex(Vector3(1,0,1))
	st.add_vertex(Vector3(0,0,1))

	st.generate_normals()

	add_child(mesh_instance)
	mesh_instance.mesh = st.commit()
