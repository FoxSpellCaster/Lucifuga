extends Node3D

func _ready():
	create_golem()

func create_golem():
	# Create main node for golem
	var golem = Node3D.new()
	add_child(golem)
	
	# Body (rough rectangular shape)
	var body_mesh = MeshInstance3D.new()
	var body_shape = BoxMesh.new()
	body_shape.size = Vector3(0.8, 1.0, 0.6)  # Wider and taller
	body_mesh.mesh = body_shape
	golem.add_child(body_mesh)
	body_mesh.position = Vector3(0, 0.5, 0)
	
	# Head (rough boulder-like shape)
	var head_mesh = MeshInstance3D.new()
	var head_shape = SphereMesh.new()
	head_shape.radius = 0.35
	head_shape.height = 0.6
	head_shape.radial_segments = 8  # Less smooth, more rocky
	head_shape.rings = 6
	head_mesh.mesh = head_shape
	golem.add_child(head_mesh)
	head_mesh.position = Vector3(0, 1.2, 0)
	
	# Left Arm (chunky and uneven)
	var left_arm = MeshInstance3D.new()
	var arm_shape = BoxMesh.new()
	arm_shape.size = Vector3(0.4, 0.8, 0.4)  # Thicker arms
	left_arm.mesh = arm_shape
	golem.add_child(left_arm)
	left_arm.position = Vector3(-0.65, 0.7, 0)
	left_arm.rotation_degrees = Vector3(0, 0, 15)  # Slight angle
	
	# Right Arm
	var right_arm = MeshInstance3D.new()
	right_arm.mesh = arm_shape
	golem.add_child(right_arm)
	right_arm.position = Vector3(0.65, 0.7, 0)
	right_arm.rotation_degrees = Vector3(0, 0, -15)
	
	# Left Leg (sturdy base)
	var left_leg = MeshInstance3D.new()
	var leg_shape = BoxMesh.new()
	leg_shape.size = Vector3(0.4, 0.7, 0.4)  # Thicker legs
	left_leg.mesh = leg_shape
	golem.add_child(left_leg)
	left_leg.position = Vector3(-0.25, 0.15, 0)
	
	# Right Leg
	var right_leg = MeshInstance3D.new()
	right_leg.mesh = leg_shape
	golem.add_child(right_leg)
	right_leg.position = Vector3(0.25, 0.15, 0)
	
	# Add collision shape
	var collision = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 1.8
	collision.shape = capsule
	golem.add_child(collision)
	collision.position = Vector3(0, 0.9, 0)
	
	# Create rocky material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.35, 0.3)  # Earthy brown
	material.roughness = 0.8  # Rough surface
	material.metallic = 0.1   # Slight sheen like wet rock
	
	# Apply material and add some noise
	for child in golem.get_children():
		if child is MeshInstance3D:
			child.set_surface_override_material(0, material)
			# Add slight random offset to vertices for rocky look
			var mesh = child.mesh
			if mesh is PrimitiveMesh:
				child.scale = Vector3(
					1.0 + randf() * 0.1,
					1.0 + randf() * 0.1,
					1.0 + randf() * 0.1
				)
