extends CanvasLayer

var map_label_to_display = "Dungeon"

func _ready():
	refresh_player_list()
	Network.connect("player_list_changed", self, "refresh_player_list")
	change_map("Dungeon", "Dungeon") # Dungeon is the default map

func refresh_player_list():
	var player_list = get_node("./Panel/PlayerInfoPanel/PlayerList")
	var text_to_display : String
	for id in Network.players_info:
		if id == 1:
			text_to_display += Network.players_info[id].name + " (Host)" + "\n"
		else:
			text_to_display += Network.players_info[id].name + "\n"
	player_list.text = text_to_display
	
func _on_StartButton_pressed():
	rpc("go_to_pre_game_lobby")

remotesync func go_to_pre_game_lobby():
	Network.sync_spawnpoints()
	get_tree().change_scene("res://Lobby/PreGameLobby/PreGameLobby.tscn")

func _on_ExitButton_pressed():
	Network.on_disconnected_from_server()
	get_tree().change_scene("res://MainMenu.tscn")

func _on_DungeonButton_pressed():
	rpc("change_map", "Dungeon", "Dungeon")

func _on_GrassyPlainsButton_pressed():
	rpc("change_map", "GrassyPlains", "Grassy Plains")

remotesync func change_map(map_name, map_label):
	Network.chosen_map = map_name
	map_label_to_display = map_label
	refresh_map_name()
	
func refresh_map_name():
	get_node("./Panel/MapPanel/ChosenMapLabel").text = map_label_to_display

