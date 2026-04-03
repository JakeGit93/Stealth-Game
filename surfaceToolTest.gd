extends MeshInstance3D

func _ready() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	st.add_vertex(Vector3(-1, 1, 0))
	st.add_vertex(Vector3(1, 1, 0))
	st.add_vertex(Vector3(-1, -1, 0))
	st.add_vertex(Vector3(1, -1, 0))
	st.index()
