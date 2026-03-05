@tool

extends MeshInstance3D

func _ready() -> void:
	# Suppose we have a quad defined by 6 vertices as follows
	var st = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Prepare attributes for add_vertex.
	st.set_normal(Vector3(0, 0, 1))
	st.set_uv(Vector2(0, 0))
	# Call last for each vertex, adds the above attributes.
	st.add_vertex(Vector3(-1, -1, 0))

	st.set_normal(Vector3(0, 0, 1))
	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(-1, 1, 0))

	st.set_normal(Vector3(0, 0, 1))
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(1, 1, 0))

	self.mesh = st.commit()
