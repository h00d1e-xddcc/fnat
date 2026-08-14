extends Node3D

@export var audio : AudioStreamPlayer3D
@export var chimera : Node3D

func _ready() -> void:
	audio.volume_db = arc.volume
	audio.play()
	if arc.night.true_night : 
		arc.save.night += 1
		arc.save_settings()
	#await get_tree().create_timer(15).timeout
	#audio.stream = preload("res://resources/sounds/user/win.wav")
	#audio.play()
	
	#await get_tree().create_timer(40).timeout
	#audio.stream = preload("res://resources/sounds/anim/noise/scream.wav")
	#audio.play()
	#chimera.visible = true
	
	await get_tree().create_timer(8).timeout
	var diff : = true
	for i in arc.night.diff.size() :
		if arc.night.diff[i] >= 25 : diff = true
		else : diff = false
	if diff : arc_event.play_sfx({"path" = "ambient/calls/" + arc.save.lange + "/14_25"})
	SceneManager.change_scene("res://prefabs/misc/main_menu.tscn", {"pattern" : "curtians"}, true)
