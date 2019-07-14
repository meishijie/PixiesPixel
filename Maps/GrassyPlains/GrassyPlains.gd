extends Node2D

func _ready():
	Network.connect("disconnected", self, "_on_disconnected")
	Network.connect("player_removed", self, "_on_player_removed")
	
func set_camera_limits():
	var player_node : String = "./" + str(get_tree().get_network_unique_id())
	get_node(player_node).get_node("./Camera2D").limit_left = 0
	get_node(player_node).get_node("./Camera2D").limit_top = 0
	get_node(player_node).get_node("./Camera2D").limit_right = 1104
	get_node(player_node).get_node("./Camera2D").limit_bottom = 416
	
func _on_player_removed(pinfo):
	despawn_player(pinfo)
	
func despawn_player(p_id):
	# Locate the player actor
	var player_node = get_node(str(p_id))
	# Mark the node for deletion
	player_node.queue_free()
	
func _on_disconnected():
	# Ideally pause the internal simulation and display a message box here.
	# From the answer in the message box change back into the main menu scene
	self.queue_free()
	get_tree().change_scene("res://MainMenu.tscn")