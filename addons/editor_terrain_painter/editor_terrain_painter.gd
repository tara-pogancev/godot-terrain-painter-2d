@tool
extends EditorPlugin

func _enter_tree():
	# Plugin must be active
	EditorInterface.get_selection().selection_changed.connect(_selection_changed)
	set_process(true)
	set_process_input(true)
	print("Plugin enabled")


func _exit_tree() -> void:
	# Disconnect signals to avoid dangling references
	EditorInterface.get_selection().selection_changed.disconnect(_selection_changed)
	print("Terrain Painter plugin disabled")


var terrain: TerrainChunk2D = null


func _selection_changed() -> void:
	terrain = null
	var selection = get_editor_interface().get_selection()
	for node in selection.get_selected_nodes():
		if node is TerrainChunk2D:
			terrain = node
			break  # Only select one for now
			
	print(terrain)


func _handles(object: Object) -> bool:
	print("Handles:" + object.get_class())
	return object is TerrainChunk2D
	

func _forward_canvas_gui_input(event) -> bool:
	# Ignore if no TerrainChunk selected
	if terrain == null:
		print('[ERROR] No terrain!')
		return false
		
	if terrain.materials.size() == 0:
		print('[ERROR] No materials!')
		return false
 
	var mat_index = 1  # safe now

   # Handle left-click paint
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		terrain.paint(mat_index, event.position)
		return true  # <--- THIS IS CRUCIAL

	return false

func _process(delta: float) -> void:
	if terrain == null:
		return
		
	update_overlays()


func _forward_canvas_draw_over_viewport(overlay) -> void:
	if terrain == null:
		return
		
	var mouse = overlay.get_local_mouse_position()
	overlay.draw_circle(mouse, terrain.brush_radius, Color(0,0,0,0.8))
